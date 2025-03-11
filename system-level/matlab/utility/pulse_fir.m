function imp = pulse_fir(h_fir, sys_ct_tuned, eld, nosum)
% Calculate the sampled pulse response 
% of a ct system, using pulse from delsig for a DAC w/ FIR filter
    dt = 1;
    ntaps = length(h_fir);
    n_imp = ntaps + 5;
    imp = zeros((n_imp/dt)+1,1);
    % [Ac, Bc, Cc, Dc] = partitionABCD(sys_ct_tuned);
    tdac = [0 1].*ones(length(sys_ct_tuned.D),1);

    % tdac(1,:) = [-1 -1];
    for i=1:ntaps
        % Bc(1,2) = -h_fir(i);
        % sys_ct_tuned_i = ss(Ac, Bc, Cc, Dc)
        tdac_i = tdac;
        tdac_i(2,:) = [i-1 i]+eld;
        if eld > 0
            tdac_i(3,:) = tdac_i(3,:)+eld;
        end
        res = squeeze(pulse(sys_ct_tuned, tdac_i, dt, n_imp, 1));
        imp = imp - res(:,2)*h_fir(i);
    end
    if eld > 0
        if nosum == 0
            imp = imp - res(:,3);
        else
            imp(:,2) = - res(:,3);
        end
    end
    if dt < 1
        imp = downsample(imp, 1/dt);
    end