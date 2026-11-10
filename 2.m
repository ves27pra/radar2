clear; clc; close all;

N = 1000; trials = 100000;
snr_dB = -10:2:15;
Pfa = 1e-3;
thr = sqrt(-2*log(Pfa));

Pd_sim = zeros(size(snr_dB));
Pfa_sim = zeros(size(snr_dB));

for i = 1:length(snr_dB)
    sigma = 10^(-snr_dB(i)/20);
    d = 0; f = 0;
    for t = 1:trials
        x = 1 + sigma*randn(1,N);
        n = sigma*randn(1,N);
        if max(x) > thr*sigma, d = d+1; end
        if max(n) > thr*sigma, f = f+1; end
    end
    Pd_sim(i) = d/trials;
    Pfa_sim(i) = f/trials;
end

Pd_th = marcumq(sqrt(2*10.^(snr_dB/10)), thr);

figure;
plot(snr_dB, Pd_sim, 'ro-', snr_dB, Pd_th, 'b--', 'LineWidth', 1.5);
grid on; xlabel('SNR (dB)'); ylabel('P_d');
title(['P_d vs SNR (P_{fa} = ', num2str(Pfa), ')']);
legend('Simulated', 'Theoretical');

figure;
pfa = logspace(-4, 0, 100);
for s = [0 5 10]
    pd = marcumq(sqrt(2*10^(s/10)), sqrt(-2*log(pfa)));
    semilogx(pfa, pd, 'LineWidth', 1.5); hold on;
end
grid on; xlabel('P_{fa}'); ylabel('P_d');
title('ROC Curves');
legend('0 dB','5 dB','10 dB');
