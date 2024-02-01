'''
Copyright 2023 Michael Koefinger

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
'''

from __future__ import division
import deltasigma as ds
import numpy as np
import scipy as sc
import control as ctr
import matplotlib.pyplot as plt

'''
Delta Sigma Testbench
Members:
    1. "Modulator" object, describes the Delta-Sigma modulator 
    2. "Decimator" object, describes a decimation filter if a time domain output at a lower sampling rate is desired
        'cascaded' option uses a cascade of integrator-comb filters (sinc^2), but this is not fully imlemented
        'movAvg' option uses a simple moving average filter, not advised for high SNR designs, as the stopband suppression is not large enough
    3. "Stimulus" object, describes the sinusoid input signal 
        Two different subclasses are available, the only difference is how the length of the input vectors gets defined
            1. TdSimStimulus: define number of periods "nPeriods"
            2. FdSimStimulus: define either "fres" or "N_FFT"
    
    Example input dictionary

    simInData = {
        "osr": 256,                # oversamping ratio
        "fs": 2**16,               # sampling freq. in Hz

        # Modulator spec
        "mod": {
            "ct": False,           # True: cont. time, False: discrete time
            "ord": 3,              # modulator order
            "k": 1.0,              # gain factor
            "nlev": 4,             # number of quantizer levels
            "optZ": 0,             # optimized zero placement of ntf (0: no, 1: all, 2: only pairs of two)
            "topology": "CIFF",    # DT: "CRFB", "CRFF", "CIFB", "CIFF" or CT: "FF", "FB"
        },

        # Decimation filter spec
        "dec": {
            "nTaps": 9000,         # FIR filter length, 20*OSR suggested
            "fc": 128,             # corner freq. of FIR
            "window": "hann",      # filter shape, "boxcar", "triangle" see scipy.signal.firwin()
            "movAvg": False, 
            "cascaded": False,
        },

        # Time domain input signal
        "stim": {
            # amplitude vector of sine signal in dBFS
            "amplVec_dB": [-3, -49.5, -115.6],
            "f": 25,               # frequency of sine in Hertz
            "nPeriods": 50,        # length of the stimulus in periods
            "dcOffset": 0.25,       # DC offset of signal
        }
}
    
'''
class Testbench:

    def __init__(self, params, interpOsr=64):
        self.__fs = params["fs"]
        self.__osr = params["osr"]

        self.__modulator = Modulator(
            params["mod"]["ct"], 
            params["mod"]["ord"],
            self.__osr,
            self.__fs,
            params["mod"]["k"],
            params["mod"]["nlev"],
            params["mod"]["optZ"],
            params["mod"]["topology"],
            params["mod"]["scaleStates"],
            params["mod"]["OBG"]
        )

        self.__modulator.realizeModulator()

        self.__decimator = Decimator(
            self.__fs,
            self.__osr,
            {
                'nTaps': params["dec"]["nTaps"],
                'fCorner': params["dec"]["fc"],
                'winFunc': params["dec"]["window"],
                'movAvg': params["dec"]["movAvg"],
                'casc': params["dec"]["cascaded"]
            }
        )

        if "nPeriods" in params["stim"]:
            self.__stimulus = TdSimStimulus(
                params["stim"]["amplVec_dB"],
                params["stim"]["f"],
                params["stim"]["dcOffset"],
                self.__fs,
                self.__osr,
                params["mod"]["nlev"],
                params["dec"]["cascaded"],
                params["stim"]["nPeriods"]
            )
        elif "fres" in params["stim"]:
            self.__stimulus = FdSimStimulus(
                params["stim"]["amplVec_dB"],
                params["stim"]["f"],
                params["stim"]["dcOffset"],
                self.__fs,
                self.__osr,
                params["mod"]["nlev"],
                params["dec"]["cascaded"],
                fres=params["stim"]["fres"]
            )
        elif "N_FFT" in params["stim"]:
             self.__stimulus = FdSimStimulus(
                params["stim"]["amplVec_dB"],
                params["stim"]["f"],
                params["stim"]["dcOffset"],
                self.__fs,
                self.__osr,
                params["mod"]["nlev"],
                params["dec"]["cascaded"],
                N_FFT=params["stim"]["N_FFT"]
            )

        self.__interpOsr = interpOsr
        self.__time = None
        self.__input = None
        self.__output = None

    def run(self, singleRun=True, useNTF = False):
        '''
        Simulate the specified DSM with the sinusoid input signals

        If a Testbench.stimulus is a TdSimStimulus, the Nyquist rate output signal and a sinc interpolation of it will be generated as well

        The following simulation results will be saved and accessed by their respective getter functions

        * time: (tDec, tInt): tuple of time vectors for decimated and sinc interpolated signals

        * input: list of (uDwnSampled, uDwnSampledInt): tuple of Nyquist rate input signal and a sinc interpolated version may be plottet with (tDec, tInt)

        * output: list of (vDec, vDecInt, v): tuple of Nyquist rate output signal and a sinc interpolated version, as well as the oversampled modulator output

        * quantInput: list of quantizer input signals

        * internal states

        * max. values of internal states

        *** Parameters ***
        singelRun: Perform the simulation only for the first element of the list of input vectors

        useNTF: Perform simulations by providing the synthesised NTF instead of the state space description of the realized DSM

        '''
        if input == None:
            raise ValueError("invalid input")

        # get modulator model
        dsmModel = self.__modulator.getSimModel()
        qLvls = self.__modulator.getQuantLevels()
        if useNTF == True:
            dsmModel = self.__modulator.getTF()[0]

        # get input signals
        n, u = self.__stimulus.getSignal()
        if type(self.__stimulus) is TdSimStimulus:
            tInt, tDec = self.__stimulus.getTimeVecs()
        elif type(self.__stimulus) is DcSimStimulus:
            tDec = self.__stimulus.getNyqRateRamp()[0]
            tInt = []
        else:
            tInt = []
            tDec = []
        
        #self.__time = (tDec, tInt)
        self.__input = []
        self.__output = []
        self.__quantInput = []
        self.__intStates = []
        self.__intStatesMax = []

        if singleRun == True:
            runCntMax = 1
        else:
            runCntMax = len(self.__stimulus.getAmplVec())

        for i in range(runCntMax):
            # simulate
            v, xn, xmax, y = ds.simulateDSM(u[i], dsmModel, nlev = self.__modulator.getQuantLevels(), x0=0)

            if type(self.__stimulus) is TdSimStimulus:
                # decimate output and input
                vDec = self.__decimator.decimate(v)
                # the cascaded decimator does only decimate by osr/2
                if self.__decimator.isCascaded():
                    q = self.__osr//2
                else:
                    q = self.__osr

                uDwnSampled = sc.signal.decimate(u[i], q=q, ftype='fir')
                # interpolate decimated sample, use resample_poly
                up = self.__interpOsr
                fsig = self.__stimulus.getStimFreq()
                nPer = self.__stimulus.getPeriodsCnt()
                fsNyq = self.__fs/self.__osr
                tInt = np.arange(0, nPer/fsig, 1/(fsNyq*up))
                # padtype="mean" gives best results for signals with dc component
                vDecInt = sc.signal.resample_poly(vDec, up, 1, padtype='mean')
                uDwnSampledInt = sc.signal.resample_poly(uDwnSampled, up, 1, padtype='mean')  

            elif type(self.__stimulus) is DcSimStimulus:
                vDec = self.__decimator.decimate(v)
                uDwnSampled = self.__stimulus.getNyqRateRamp()[1]
                vDecInt = []
                uDwnSampledInt = []
            else:
                vDec = []
                uDwnSampled = []
                vDecInt = []
                uDwnSampledInt = []
            
            # assemble lists
            self.__input.append((uDwnSampled, uDwnSampledInt))
            self.__output.append((vDec, vDecInt, v))
            self.__quantInput.append(y)
            self.__intStates.append(xn)
            self.__intStatesMax.append(xmax)

        self.__time = (tDec, tInt)

    def getQuantGainFromSim(self):
        '''Determine the quantizer gain k from the simulation results. See Bluebook p. 35f'''
        runCnt = len(self.__output)
        kSimVec = np.zeros(runCnt)
        for i in range(runCnt):
            kSimVec[i] = np.inner(self.__output[i][2], self.__quantInput[i])/np.inner(self.__quantInput[i], self.__quantInput[i])
        return np.mean(kSimVec)
    
    def _calcTheoreticalSpectrumFromSim(self, f):
        '''
        Use the simulated quanitzer gain to calculate the NTF in dependence of the quantizer gain

        Note: may use ds.calcluateTF() instead of control toolbox
        '''
        if self.__output == None:
            raise ValueError("Run simulations first!")

        k = self.getQuantGainFromSim()
        ntf = self.__modulator.getSynthNTF()
        fs = self.__stimulus.getSamplingFreq()
        ntf_tf = sc.signal.ZerosPolesGain(ntf[0], ntf[1], ntf[2], dt=1/fs).to_tf()
        ntf_z = ctr.TransferFunction(ntf_tf.num, ntf_tf.den, ntf_tf.dt)
        ntfk_z = ntf_z/(k+(1-k)*ntf_z)
        ntfk = ntfk_z.returnScipySignalLTI()[0][0]
        Sq = 4/3/((self.__stimulus.getFullScale()/2)**2)*self.__winNBW*np.abs(ds.evalTF(ntfk.to_zpk(), np.exp(2*1.j*np.pi*f)))**2
        return Sq

    @staticmethod
    def calcFFT(signal, window, N):
        return np.fft.fft(signal*window, N)
    
    @staticmethod
    def calcPSDSinScaled(signal, fs, N_FFT, FS):
        win = np.hanning(N_FFT)
        winNorm1 = np.linalg.norm(win,1)
        winNorm2 = np.linalg.norm(win,2)
        NBW= (winNorm2/winNorm1)**2
        scale = ((FS/4)*winNorm1)
        S = Testbench.calcFFT(signal, win, N_FFT)/scale

        return {'psd':S, 'nbw':NBW}

    def calcPSDParam(self):
        '''Calculate SNR, SNDR and IBN using a Hanning Window and PSD in dBFS'''
        fres = self.__stimulus.getFrequencyResolution()
        N_FFT = self.__stimulus.getSampleCnt()
        fs = self.__stimulus.getSamplingFreq()
        fb = fs/self.__osr/2
        nb = 3;
        #N_FFT = int(np.ceil(fs/fres))
        fbin = int(self.__stimulus.getStimFreq()/fres)
        win = np.hanning(N_FFT)
        winNorm1 = np.linalg.norm(win,1)
        winNorm2 = np.linalg.norm(win,2)
        self.__winNBW = (winNorm2/winNorm1)**2
        scale = ((self.__stimulus.getFullScale()/4)*winNorm1)

        dcBins = np.r_[:(nb-1)/2+1];
        dcBins = dcBins.astype(int)
        signalBins = np.r_[fbin-(nb-1)/2:fbin+(nb-1)/2+1]
        signalBins = signalBins.astype(int)
        hd2 = fbin*2
        hd3 = fbin*3
        hd2Bins = np.r_[hd2-(nb-1)/2:hd2+(nb-1)/2+1]
        hd2Bins = hd2Bins.astype(int)
        hd3Bins = np.r_[hd3-(nb-1)/2:hd3+(nb-1)/2+1]
        hd3Bins = hd3Bins.astype(int)
        inbandBins = np.r_[:fb/fres+1]
        inbandBins = inbandBins.astype(int)
        noiseBinsSNDR = np.setdiff1d(inbandBins, np.hstack((dcBins,signalBins)))
        noiseBinsSNDR = noiseBinsSNDR.astype(int)
        noiseBinsSNR = np.setdiff1d(inbandBins, np.hstack((dcBins,signalBins,hd2Bins, hd3Bins)))
        noiseBinsSNR = noiseBinsSNR.astype(int)
        noiseBinsSNHD3R = np.setdiff1d(inbandBins, np.hstack((dcBins, signalBins, hd2Bins)))
        noiseBinsSNHD3R = noiseBinsSNHD3R.astype(int)

        self.__snrVec = []
        self.__sndrVec = []
        self.__snhd3rVec = []
        self.__ibnVec = []
        self.__psdLinScaledVec = []
        for i in range(len(self.__output)):
            v = self.__output[i][2]
            V = self.calcFFT(v, win, N_FFT)/scale
            #V = np.fft.fft(v*win, N_FFT)/scale
            spwr = np.sum(np.abs(V[signalBins])**2)
            npwrSNDR = np.sum(np.abs(V[noiseBinsSNDR])**2)
            npwrSNHD3R = np.sum(np.abs(V[noiseBinsSNHD3R])**2)
            npwrSNR = np.sum(np.abs(V[noiseBinsSNR])**2)
            self.__snrVec.append(10*np.log10(spwr/npwrSNR))
            self.__sndrVec.append(10*np.log10(spwr/npwrSNDR))
            self.__snhd3rVec.append(10*np.log10(spwr/npwrSNHD3R))
            self.__ibnVec.append(10*np.log10(4*npwrSNR*self.__winNBW))
            self.__psdLinScaledVec.append(V)

        return {"SNR": self.__snrVec, "SNDR": self.__snrVec, "IBN": self.__ibnVec, "NBW": self.__winNBW}

    def simulateSNRWrapper(self, fin=None, useNTF=False):
        if useNTF == True:
            dsmModel = self.__modulator.getTF()[0]
        else:
            dsmModel = self.__modulator.realizeModulator()

        if fin == None:
            snr, _ = ds.simulateSNR(dsmModel, self.__osr, self.__stimulus.getAmplVec(), nlev=self.__modulator.getQuantLevels(), f=self.__stimulus.getStimFreq()/self.__stimulus.getSamplingFreq())
        else:
            snr, _ = ds.simulateSNR(dsmModel, self.__osr, self.__stimulus.getAmplVec(), nlev=self.__modulator.getQuantLevels(), f=fin/self.__stimulus.getSamplingFreq())
        print("SQNR in dB: ", snr)
        return snr

    def getSpectrum(self):
        return (self.__VdbVec, self.__VAvgVec, self.__fsignalBin)

    def getPSDParams(self):
        return {"SNR": self.__snrVec, "SNDR": self.__sndrVec, "IBN": self.__ibnVec, "NBW": self.__winNBW}

    def getPSD(self):
        return {"PSD": self.__psdLinScaledVec, "NBW": self.__winNBW}

    def getResult(self):
        ''' Returns simulated vectors from Testbench.run()
                ret['time'] ... tuple of time vectors (tNqyRate, tOsr)
                ret['in'] ... vector of tuples of vectors (uDwnSampled, uDwnSampledInt)
                ret['out'] ... vector of tuples of vectors (vDec, vDecInt, v)
        '''
        return {"time": self.__time, "in": self.__input, "out": self.__output, "y": self.__quantInput}

    def setFdStimFrequency(self, fstim=None, fres = None):
        if type(self.__stimulus) is FdSimStimulus:
            self.__stimulus = FdSimStimulus(self.__stimulus.getAmplVec(), fsignal=fstim, offset = self.__stimulus.getDCOffset(), fs = self.__fs, osr=self.__osr, nlev = self.__modulator.getQuantLevels(), fres=fres)
        else:
            print("Warning! Wrong usage!")
        
    def plotResult(self, zoomXY=(False, False), zoomFactY=0, show={"in": (True, True), "out": (True, True, False)}):
        inAmplVec = self.__stimulus.getAmplVec()
        for i in range(len(self.__output)):
            plt.figure(figsize=(15,10))
            plt.title("Quantizer Output of DSM, Ampl.: {0} dBFS (FS={1}), Freq.: {2} Hz, fs: {3} Hz".format(inAmplVec[i], self.__stimulus.getFullScale(), self.__stimulus.getStimFreq(), self.__stimulus.getSamplingFreq()), fontsize='18')
            if show["in"][0] == True:
                plt.plot(self.__time[0], self.__input[i][0], 'bo', label='Input, decimated')
            if show["in"][1] == True:
                plt.plot(self.__time[1], self.__input[i][1], 'b-', label='Input, sinc-interpol.')
            if show["out"][0] == True:
                plt.plot(self.__time[0], self.__output[i][0], 'ro', label='Output, decimated')
            if show["out"][1] == True:
                plt.plot(self.__time[1], self.__output[i][1], 'r-', label='Output, sinc-interpol.')
            plt.grid()

            maxtime = max(self.__time[0])
            zoomMax = maxtime*0.55
            zoomMin = maxtime*0.45
            tmaxIdx = np.where(self.__time[0]>=zoomMax)[0][0]
            tminIdx = np.where(self.__time[0]<=zoomMin)[0][-1]
            if (zoomXY[0] == True):
                plt.xlim([zoomMin, zoomMax])
            if (zoomXY[1] == True):
                outMax = max(self.__output[i][0][tminIdx:tmaxIdx])
                outMin = min(self.__output[i][0][tminIdx:tmaxIdx])
                plt.ylim([outMin*(1-zoomFactY), outMax*(1+zoomFactY)])

            plt.xlabel("t in s", fontsize='16')
            plt.ylabel("Amplitude in V", fontsize='16')
            plt.legend(loc=4, fontsize='16')

            if show["out"][2] == True:
                plt.figure(figsize=(15,10))
                plt.title("Quantizer Output of DSM, Ampl.: {0} dBFS (FS={1}), Freq.: {2} Hz, fs: {3} Hz".format(inAmplVec[i], self.__stimulus.getFullScale(), self.__stimulus.getStimFreq(), self.__stimulus.getSamplingFreq()), fontsize='18')
                plt.plot(self.__time[1], self.__output[i][2], 'ro')
                plt.grid()
                plt.xlabel("t in s", fontsize='16')
                plt.ylabel("Output Level", fontsize='16')

    def plotIntStates(self, options={"separateWins": False, "zoomToEnd": False}):
        zoomToEndFactor = 0.8
        endIdx = len(self.__time[1])-1
        newStartIdx = int(np.floor(zoomToEndFactor*endIdx))
        inAmplVec = self.__stimulus.getAmplVec()

        for i in range(len(self.__output)):
            if options["separateWins"] == False:
                plt.figure(figsize=(15,10))
                plt.title("Internal States of DSM, Ampl.: {0} dBFS".format(inAmplVec[i]), fontsize='16')
                for j in range(len(self.__intStates[i])):
                    plt.plot(self.__time[1], self.__intStates[i][j], "-o", label='x{0}'.format(j+1))
                plt.plot(self.__time[1], self.__quantInput[i], "-o", label='y')
                if options["zoomToEnd"] == True:
                    plt.xlim([self.__time[1][newStartIdx], self.__time[1][endIdx]])
                plt.grid()
                plt.xlabel("t in s", fontsize='14')
                plt.ylabel("Amplitude in V", fontsize='14')
                plt.legend(loc=4)
            else:
                for j in range(len(self.__intStates[i])+1):
                    plt.figure(figsize=(15,10))
                    if j < len(self.__intStates[i]):
                        plt.title("Internal State x{0} of DSM, Ampl.: {1} dBFS".format(j+1, inAmplVec[i]), fontsize='16')
                        plt.plot(self.__time[1], self.__intStates[i][j], "-o", label='x{0}'.format(j+1))
                    else:
                        plt.title("Quantizer Input y of DSM, Ampl.: {0} dBFS".format(inAmplVec[i]), fontsize='16')
                        plt.plot(self.__time[1], self.__quantInput[i], "-o", label='y')
                    if options["zoomToEnd"] == True:
                        plt.xlim([self.__time[1][newStartIdx], self.__time[1][endIdx]])
                    plt.grid()
                    plt.xlabel("t in s", fontsize='14')
                    plt.ylabel("Amplitude in V", fontsize='14')
                    plt.legend(loc=4)

    def plotQuantTF(self):
        inAmplVec = self.__stimulus.getAmplVec()
        plt.figure(figsize=(12,8))
        for i in range(len(self.__output)):
            v = self.__output[i][2]
            y = self.__quantInput[i]
            plt.plot(y,v, 'o', label='{0} dBFS'.format(inAmplVec[i]))
        plt.grid()
        plt.legend(loc=4, fontsize='16')
        plt.title("{0}-Level Quantizer".format(self.__modulator.getQuantLevels()), fontsize='18')
        plt.ylabel("v", fontsize='16')
        plt.xlabel("y", fontsize='16')

    def plotPSD(self, scaleFreqByTestBenchFs=False):
        fres = self.__stimulus.getFrequencyResolution()
        N_FFT = self.__stimulus.getSampleCnt()
        fs = self.__stimulus.getSamplingFreq()
        fb = fs/(2*self.__osr)
        fs_tb = self.__fs
        #N_FFT = int(np.ceil(self.fs/fres))
        maxBin = int(np.round(N_FFT/2))
        fbin = int(self.__stimulus.getStimFreq()//fres)
        fVec = np.r_[0:maxBin]*fres
        for i in range(len(self.__output)):
            psd = 20*np.log10(np.abs(self.__psdLinScaledVec[i]))
            fVecSmoothed, psdAvg = ds.logsmooth(self.__psdLinScaledVec[i], fbin)
            Sq = self._calcTheoreticalSpectrumFromSim(fVecSmoothed)
            if scaleFreqByTestBenchFs == True and fs==1:
                fVec = fVec*fs_tb
                fVecSmoothed = fVecSmoothed*fs_tb
                fb = fb*fs_tb
            elif scaleFreqByTestBenchFs == False and fs>1:
                fVecSmoothed = fVecSmoothed*fs
            plt.figure(figsize=(12,8))
            plt.plot(fVec, psd[0:maxBin], label="Hann windowed")
            plt.plot(fVecSmoothed, psdAvg, label='Smoothed FFT')
            plt.plot(fVecSmoothed, ds.dbp(Sq), label="Theoretical spectrum")
            plt.vlines(fb, 0,int(min(psd)), colors='red', linestyles='dashed')
            plt.title("PSD of Modulator Output, NBW=%0.1e" %self.__winNBW,fontsize='16')
            plt.ylabel("PSD in dBFS/NBW", fontsize='14')
            plt.xlabel("f in Hz", fontsize='14')
            plt.xscale('log')
            plt.grid()
            plt.legend(loc=4, fontsize='14')

    def plotDcTf(self):

        if type(self.__stimulus) is DcSimStimulus:
            
            plt.figure()
            plt.plot(self.__input[0][0], self.__output[0][0])

    def plotSNR(self, coarseSteps=[-170, -20, 20], fineSteps=[-15, 0, 2]):
        # assemble input vector
        # TODO: check input arguments
        inStepsCoarse = coarseSteps[2]
        inMinCoarse_dBFS = coarseSteps[0]
        inMaxCoarse_dBFS = coarseSteps[1]
        inStepsFine = fineSteps[2]
        inMinFine_dBFS = fineSteps[0]
        inMaxFine_dBFS = fineSteps[1]
        inputVec_dBFS = np.linspace(inMinCoarse_dBFS, inMaxCoarse_dBFS, int(np.floor((inMaxCoarse_dBFS-inMinCoarse_dBFS)/inStepsCoarse)) + 1);
        inputVec_dBFS = np.append(inputVec_dBFS, np.linspace(inMinFine_dBFS, inMaxFine_dBFS, int(np.floor((inMaxFine_dBFS-inMinFine_dBFS)/inStepsFine)) + 1));

        sqnr_s, _ = ds.simulateSNR(self.__modulator.getSynthNTF(), self.__osr, amp=inputVec_dBFS, nlev=self.__modulator.getQuantLevels(), f=self.__stimulus.getStimFreq()/self.__stimulus.getSamplingFreq());
        sqnr_r, _ = ds.simulateSNR(self.__modulator.realizeModulator(), self.__osr, amp=inputVec_dBFS, nlev=self.__modulator.getQuantLevels(), f=self.__stimulus.getStimFreq()/self.__stimulus.getSamplingFreq())
        
        # Plot SQNR over Input
        plt.figure(figsize=(10,5));
        plt.title("Simulated SQNR")
        plt.plot(inputVec_dBFS, sqnr_s, '-o', label='synth. NTF')
        plt.plot(inputVec_dBFS, sqnr_r, '-o', label='realized NTF')
        plt.grid(True)
        plt.xlabel("Input Amplitude in dBFS");
        plt.ylabel("SQNR in dB");
        plt.legend(loc=2)

        self.__sqnrVecSynth = sqnr_s
        self.__sqnrVecRealized = sqnr_r
        self.__inputVecdBFS = inputVec_dBFS
    
    def getIntStatesMax(self):
        return self.__intStatesMax

    def getModulatorObj(self):
        return self.__modulator

    def getDecimatiorObj(self):
        return self.__decimator

    def getStimulusObj(self):
        return self.__stimulus
    
    def getSNRPlotData(self):
        return {'synth':(self.__inputVecdBFS, self.__sqnrVecSynth), 'real':(self.__inputVecdBFS, self.__sqnrVecRealized)}
    
    def exportSNRPlotData(self, fileName='data.txt', useNTF=True):
        if useNTF == True:
            sqnrVec = self.__sqnrVecSynth
        else:
            sqnrVec = self.__sqnrVecRealized

        np.savetxt(fileName, np.column_stack([self.__inputVecdBFS, sqnrVec]), header='Input SQNR', comments='')

    def exportPSDPlotData(self, fileName='psd_data.txt', runIdx=0, skipNonAvgPsd=True, scaleFreqByTestBenchFs=False):
        fres = self.__stimulus.getFrequencyResolution()
        fs = self.__stimulus.getSamplingFreq()
        fs_tb = self.__fs
        N_FFT = int(np.ceil(fs/fres))
        fbinMax = N_FFT//2+1
        fbin = self.__stimulus.getStimFreq()*N_FFT//fs
        fVec = np.r_[0:fbinMax]*fres
        SdB = (20*np.log10(np.abs(self.__psdLinScaledVec[runIdx])))[0:fbinMax]
        fVecAvg, SavgdB = ds.logsmooth(self.__psdLinScaledVec[runIdx], fbin)
        Stheo = self._calcTheoreticalSpectrumFromSim(fVecAvg)
        StheodB = ds.dbp(Stheo)
        if scaleFreqByTestBenchFs == True:
            fVecAvg = fVecAvg*fs
        if skipNonAvgPsd==False:
            np.savetxt(fileName, np.column_stack([fVec, SdB]), header='f S', comments='')
        fileStr = fileName.split('.')
        fileNameAvg = fileStr[0] + '_avg.' + fileStr[1]
        np.savetxt(fileNameAvg, np.column_stack([fVecAvg, SavgdB, StheodB]), header='f Savg Stheo', comments='')
        fileNameNBW = fileStr[0] + '_nbw.' + fileStr[1]
        np.savetxt(fileNameNBW, np.column_stack([self.getPSD()['NBW']]), header='NBW', comments='')

    def exportDecimatedSignals(self, fileName='tdsim_data.txt', runIdx=0, tStartRel=0, tStopRel=1):
        '''Save Nyquist-rate signals of in- and output, include interpolated signals for plotting

            expects Testbench.__stimulus to be a TdSimStimulus

            runIdx ... chose simulation run number if multiple input amplitudes were specified

            tStartRel ... relative start time of exported signals
            tStopRel ... relative stop time of exported signals
            
        '''
        if type(self.__stimulus) is TdSimStimulus:
            nPer = self.__stimulus.getPeriodsCnt()
            fsig = self.__stimulus.getStimFreq()
        else:
            raise TypeError("Stimulus has wrong type!")
        
        # Get simulation data
        simRes = self.getResult()
        
        # Convert relative input times to index values
        fsNyq = self.__fs/self.__osr
        fsInt = fsNyq*self.__interpOsr
        tMax = nPer/fsig
        perSig = 1/fsig
        tStepDec = 1/fsNyq
        tStepInt = 1/fsInt
        perIdx = perSig/tStepInt
        tStart = tStartRel*tMax
        tStop = tStopRel*tMax

        perIdxDec = int(perSig//tStepDec)
        perIdxInt = int(perSig//tStepInt)

        startIdxDec = int(tStart//tStepDec)
        stopIdxDec = int(tStop//tStepDec)
        startIdxInt = int(tStart//tStepInt)
        stopIdxInt = int(tStop//tStepInt)

        # round index to next period
        startIdxDec_ = int(np.floor(startIdxDec//perIdxDec)-1)*perIdxDec
        stopIdxDec_ = int(stopIdxDec//perIdxDec)*perIdxDec
        startIdxInt_ = int(np.floor(startIdxInt/perIdxInt))*perIdxInt
        stopIdxInt_ = int(np.ceil(stopIdxInt/perIdxInt)+1)*perIdxInt

        tDecVec = simRes['time'][0][startIdxDec_:stopIdxDec_]
        inDec = simRes['in'][runIdx][0][startIdxDec_:stopIdxDec_]
        outDec = simRes['out'][runIdx][0][startIdxDec_:stopIdxDec_]
        tIntVec = simRes['time'][1][startIdxInt_:stopIdxInt_]
        inInt = simRes['in'][runIdx][1][startIdxInt_:stopIdxInt_]
        outInt = simRes['out'][runIdx][1][startIdxInt_:stopIdxInt_]

        fileStr = fileName.split('.')
        fileNameDec = fileStr[0] + '_dec.' + fileStr[1]
        fileNameInt = fileStr[0] + '_int.' + fileStr[1]

        np.savetxt(fileNameDec, np.column_stack([tDecVec, inDec, outDec]), header='t in out', comments='')
        np.savetxt(fileNameInt, np.column_stack([tIntVec, inInt, outInt]), header='t in out', comments='')


    def setStimulusObj(self, stimObj):
        if type(stimObj) is TdSimStimulus or type(stimObj) is FdSimStimulus or type(stimObj) is DcSimStimulus:
            newFsample = stimObj.getSamplingFreq()
            newNlev = int(stimObj.getFullScale()/2+1)
            nLev = self.__modulator.getQuantLevels()
            if newNlev != nLev:
                raise ValueError('Fullscale does not match modulator quantizer levels!')
            self.__stimulus = stimObj
        else:
            raise ValueError('Wrong input object!')    
        
    def verifyOBG(self, runIdx=0):
       if type(self.__stimulus) is FdSimStimulus:
           N_FFT = self.__stimulus.getSampleCnt()
       else:
           raise ValueError("Wrong Stimulus Obj!")
       
       FS = self.__stimulus.getFullScale()
       # psd of output
       p1 = Testbench.calcPSDSinScaled(self.__output[runIdx][2], self.__fs, N_FFT, FS)
       # psd of quant. noise
       p2 = Testbench.calcPSDSinScaled(self.__output[runIdx][2]-self.__quantInput[runIdx], self.__fs, N_FFT, FS)

       p = p1['psd']/p2['psd']
       obg_sim = np.abs(p)[N_FFT//2]
       obg_synth = self.__modulator.getOBG()

       return (obg_sim, obg_synth)
        
class Modulator:
    
    def __init__(self, ct=False, order=2, osr=64, fs=None, k=1.0, nLev=2, optZeros=0, topology="CIFF", scale=False, obg=1.5):
        self._ct = ct
        self._order = order
        self._osr = osr
        self._fs = fs
        self._k = k
        self._nLev = nLev
        self._opt = optZeros
        self._top = topology
        self._ABCD = None
        self._scale = scale
        self._obg = obg

    def realizeModulator(self, verbose = False):
        '''Realize a NTF with the initialized specs. Returns ABCD representation of modulator.'''
        ntf_synth = ds.synthesizeNTF(self._order, self._osr, opt=self._opt, H_inf=self._obg)

        if verbose == True:
            print("Synthesized NTF")
            print(ds.pretty_lti(ntf_synth))

        if self._ct == True:
            ABCDct, tdac = ds.realizeNTF_ct(ntf_synth, form=self._top)
            self._ABCDct = ABCDct
            self._tdac = tdac
            sys_c2d, Gp = ds.mapCtoD(ABCDct, tdac)
            ABCD = np.vstack((
                  np.hstack((sys_c2d[0], sys_c2d[1])),
                  np.hstack((sys_c2d[2], sys_c2d[3]))
            ))
        else:
            a, g, b, c = ds.realizeNTF(ntf_synth, form=self._top)
            #b = np.hstack(( # Use a single feed-in for the input
            #   np.atleast_1d(b[0]),
            #   np.zeros((b.shape[0] - 1, ))
            #))
            ABCD = ds.stuffABCD(a, g, b, c, form=self._top)

        if self._scale == True:
            (ABCDs, umax, scalingMat) = ds.scaleABCD(ABCD, nlev=self._nLev)
            ABCD = ABCDs 
        else:
            umax = None;
            
        self._ABCD = ABCD
        if umax != None:
            self._msi = umax/(self._nLev-1)     # normalize to full scale
        else:
            self._msi = 1
        (ntf, stf) = ds.calculateTF(ABCD, k=self._k)
        self._ntf = ntf
        self._stf = stf
        self._ntf_s = ntf_synth
        
        if verbose == True:
            print("Realized NTF")
            print(ds.pretty_lti(ntf))
            print("Realized STF")
            print(ds.pretty_lti(stf))
            
        return self._ABCD

    def getSimModel(self):
        return self._ABCD

    def getTF(self):
        return (self._ntf, self._stf)

    def printTF(self):
        print("Realized NTF")
        print(ds.pretty_lti(self._ntf))
        print("Realized STF")
        print(ds.pretty_lti(self._stf))

    def plotPzMapNTF(self):
        plt.figure()
        ds.plotPZ(self._ntf)
        plt.title("PZ Map of NTF")

    def plotPzMapSTF(self):
        plt.figure()
        ds.plotPZ(self._stf)
        plt.title("PZ Map of STF")

    def DocumentNTFWrapper(self):
        '''Plots PZ map of NTF and frequency response of NTF and STF'''
        ds.DocumentNTF(self._ABCD, self._osr)

    def getMSI(self):
        return self._msi

    def getSynthNTF(self):
        return self._ntf_s

    def getQuantLevels(self):
        return self._nLev

    def getModCoeff(self):
        if self._ct == True:
            topo = 'CI'+self._top
        else:
            topo = self._top

        a, g, b, c = ds.mapABCD(self._ABCD, form=topo)

        return [a,g,b,c]

    def getStateSpaceMat(self):
        if self._ct == True:
            return self._ABCDct
        else:
            return self._ABCD
        

    def setStateSpaceMat(self, ssMatrix):
        if self._ct == True:
            sys_c2d, Gp = ds.mapCtoD(ssMatrix, self._tdac)
            self._ABCD = np.vstack((
                  np.hstack((sys_c2d[0], sys_c2d[1])),
                  np.hstack((sys_c2d[2], sys_c2d[3]))
            ))
        else:
            self._ABCD = ssMatrix

    def getOBG(self):
        return self._obg
            

class SamplingRateConverter:
    '''Parent Class for "Decimator" and "Interpolator" Classes. Creates a FIR Filter and provides basic getter and plot functions.'''
    def __init__(self, fs=None, ratio=None, filter={'nTaps': None, 'fCorner': None, 'winFunc': "boxcar", 'movAvg': False}):
        self._fs = fs
        self._ratio = ratio
        self._nTaps = filter["nTaps"]
        self._fCorner = filter["fCorner"]
        self._window = filter["winFunc"]
        self._movAvg = filter["movAvg"]
        self._filterIr = []
        self._filterDlti = []

        if self._movAvg == True:
            self._filterIr.append(1/(self._nTaps)*np.ones(self._nTaps))
            self._filterDlti.append(sc.signal.dlti(self._filterIr[0], 1, dt=1/self._fs))
        else:
            self._filterIr.append(sc.signal.firwin(self._nTaps, cutoff = self._fCorner/self._fs, window = self._window, pass_zero = True, scale=True, fs=1))
            self._filterDlti.append(sc.signal.dlti(self._filterIr[0], 1, dt=1/self._fs))

    def getFilter(self):
        '''Returns tuple of impulse response list and Dlti list'''
        return (self._filterIr, self._filterDlti)

    def plotBode(self):  
        for i in range(len(self._filterIr)):
            omega, h = sc.signal.freqz(self._filterIr[i], worN=4096)
            plt.figure(figsize=(12,8))
            plt.title("Magnitude of Decimation Filter", fontsize='16')
            plt.semilogx(omega/(2*np.pi)*self._fs, 20*np.log10(np.abs(h)))
            plt.grid('both', 'both')
            plt.xlabel("f in Hz", fontsize='14')
            plt.ylabel("Magnitude in dB", fontsize='14')
            plt.figure(figsize=(12,8))
            plt.title("Phase of Decimation Filter", fontsize='16')
            plt.semilogx(omega/(2*np.pi)*self._fs, np.angle(h)*180/np.pi)
            plt.grid('both', 'both')
            plt.xlabel("f in Hz", fontsize='14')
            plt.ylabel("Phase in Deg", fontsize='14')

class Decimator(SamplingRateConverter):
    '''Decimator Class'''
    def __init__(self, fs=None, ratio=None, filter={'nTaps': None, 'fCorner': None, 'winFunc': "boxcar", 'movAvg': False, 'casc': False}):
        self._cascaded = filter["casc"]
        del filter["casc"]
        SamplingRateConverter.__init__(self, fs, ratio, filter)

        if self._cascaded == True:
            # use a cascade of CIC filters and a compensation FIR filter
            # this is a specific impl for this thesis, see Bluebook p. 463
            # see decimator.ipynb for the calculations
            self._cicOrdVec = [4, 5, 6, 7, 10, 19]
            self._osrVec = [64, 32, 16, 8, 4, 2]
            self._compCoeff = [0.06664257, -0.40045439, 1.6695223, -0.40045439, 0.06664257]

            # delete filter designed by parent class
            self._filterIr = []
            self._filterDlti = []

    def decimate(self, input):
        '''Applies FIR filter and downsamples by given ratio. /
        If 'cascaded' is set to 'True', a cascade of CIC filters followed by a FIR compensation filter is used. /
        The latter is specifically designed for design target of this thesis (osr=128) but does only decimate by 64. /
        Thus the resulting data rate is twice the desired nyquist rate.'''

        if self._movAvg == True or self._cascaded == False:
            # In the case of a moving avg. filter or a FIR
            # scipy provides different ways for decimation/resampling
            # 'decimate' uses 'upfirdn' internally 
            return sc.signal.decimate(input, q=self._ratio, ftype=self._filterDlti[0])
            #return sc.signal.upfirdn(self.filterIr[0], input, up=1, down=self.ratio)
            #return sc.signal.resample_poly(input, 1, self.ratio)
        else:
            # CIC Casc. + COMP Filter, not fully functional yet
            signal = input
            for i in range(len(self._cicOrdVec)):
                res = ds.sinc_decimate(signal, self._cicOrdVec[i], 2)
                signal = res
    
            return sc.signal.lfilter(self._compCoeff, 1, res)

    def isCascaded(self):
        return self._cascaded

class Interpolator(SamplingRateConverter):
    '''Interpolator Class'''
    def interpolate(self, input):
        '''Upsamples by given ratio and applies FIR filter'''
        return sc.signal.upfirdn(self._filterIr[0], input, up=self._ratio, down=1)


class Stimulus:
    '''Stimulus Class'''
    # Improvements: implement linear increase instead of step to reach the given DC offset

    def __init__(self, amplVec_dB=None, fsignal=None, offset=None, fs=None, osr=None, nlev=None, cascDec=False):
        self._amplVec = amplVec_dB  # in dB
        self._fsignal = fsignal
        self._fs = fs
        self._dc = offset
        self._nVec = []
        self._signalVec = []

        # the cascaded decimator does only decimate by osr/2
        if cascDec == True:
            self._osr = osr//2
        else:
            self._osr = osr

        # full scale of quantizer
        delta = 2
        M = nlev - 1
        self._FS = 2*(M/2*delta)

    def getSignal(self):
        return (self._nVec, self._signalVec)

    def getStimFreq(self):
        return self._fsignal

    def getFullScale(self):
        return self._FS

    def getAmplVec(self):
        return self._amplVec
    
    def getDCOffset(self):
        return self._dc

    def getSamplingFreq(self):
        return self._fs

    def plotStim(self, idx=0, axis = None):
        if len(self._nVec) == 0 or len(self._signalVec) == 0:
            raise ValueError('Nothing to plot!')    
        
        plt.figure(figsize=(15,10))
        plt.title("Stimulus, Ampl.: {0} dBFS".format(self._amplVec[idx]), fontsize='16')
        plt.plot(self._nVec, self._signalVec[idx], 'b')
        plt.grid()
        plt.xlabel("n", fontsize='14')
        plt.ylabel("Amplitude in V", fontsize='14')
        if axis != None:
            if axis[0] != None:
                plt.xlim(axis[0])
            if axis[1] != None:
                plt.ylim(axis[1])

class TdSimStimulus(Stimulus):
    '''Stimulus for Time Domain Simulation Results, 
        specify number of periods of the sinusoidal signal "nPeriods" to determine length of input vector
    '''
    def __init__(self, amplVec_dB=None, fsignal=None, offset=None, fs=None, osr=None, nlev=None, cascDec=False, nPeriods=None):
        Stimulus.__init__(self, amplVec_dB, fsignal, offset, fs, osr, nlev, cascDec)
        self._nPeriods = nPeriods

        # number of samples
        N = int((self._nPeriods/self._fsignal)*self._fs)

        self._nVec = np.arange(0, N)
        self._tOS = np.arange(0, self._nPeriods/self._fsignal, 1/self._fs)
        self._tNyq = np.arange(0, self._nPeriods/self._fsignal, self._osr/self._fs)

        # "soft_start" from simulateSNR.py
        self._Ntransient = 200
        transient = 0.5*(1 - np.cos(2*np.pi/self._Ntransient * np.arange(self._Ntransient/2)))

        self._signalVec = np.zeros((len(self._amplVec), len(self._nVec)))
        for i in range(len(self._amplVec)):
            sig = ds.undbv(self._amplVec[i])*(self._FS/2)*np.sin(2*np.pi*(self._fsignal/self._fs)*self._nVec)+self._dc
            sig[:self._Ntransient//2] = sig[:self._Ntransient//2] * transient
            self._signalVec[i,:] = sig

    def getTimeVecs(self):
        return (self._tOS, self._tNyq)

    def getPeriodsCnt(self):
        return self._nPeriods

    def getTransientSamplCnt(self):
        return self._Ntransient

class FdSimStimulus(Stimulus):
    '''Stimulus for Frequency Domain Simulation Results, 
        specify either the number of samples "N_FFT" or the desired frequency resolution of the FFT "fres" 
        to set the length of input vector
    '''
    def __init__(self, amplVec_dB=None, fsignal=None, offset=None, fs=1, osr=None, nlev=2, cascDec=False, fres=None, N_FFT=None):
        Stimulus.__init__(self, amplVec_dB, fsignal, offset, fs, osr, nlev, cascDec)
        if fres == None:
            if N_FFT == None:
                N_FFT = 2**13

            self._NFFT = N_FFT
            self._fres = self._fs/self._NFFT
        else:
            self._fres = fres
            self._NFFT = int(np.ceil(self._fs/self._fres))

        self._nVec = np.arange(0, self._NFFT)
        
        self._signalVec = np.zeros((len(self._amplVec), len(self._nVec)))
        for i in range(len(self._amplVec)):
            sig = ds.undbv(self._amplVec[i])*(self._FS/2)*np.sin(2*np.pi*(self._fsignal/self._fs)*self._nVec)+self._dc
            self._signalVec[i,:] = sig

    def getFrequencyResolution(self):
        return self._fres
    
    def getSampleCnt(self):
        return self._NFFT
    
class DcSimStimulus(Stimulus):
    '''
    Stimulus for DC transfer function simulations
    Input signal is a ramp starting from -M to +M
    M ... steps of the quantizer 
    SQNRgoal ... exprected peak SQNR, used to calculate step size of the ramp
    '''

    def __init__(self, fs=None, osr=None, nlev=None, SQNRgoal=None, cascDec=False, ):
        Stimulus.__init__(self, [0], 0, 0, fs, osr, nlev, cascDec)

        # lsb in terms of toolbox quantizer model
        inFullScale = self._FS+2
        self._lsb = inFullScale*2**(-(SQNRgoal-1.76)/6.02)
        step = self._lsb/5
        ramp = np.r_[-inFullScale/2:inFullScale/2+step:step]
        rampUpSampled = ramp.repeat(self._osr)
        self._nVec = np.arange(0, len(rampUpSampled))
        self._signalVec = np.zeros((1, len(self._nVec)))
        self._signalVec[0] = rampUpSampled
        self._nyqRateRamp = ramp
        self._nyqRateNVec = np.arange(0, len(ramp))

    def getNyqRateRamp(self):
        return (self._nyqRateNVec, self._nyqRateRamp)