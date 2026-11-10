
% Radar Target Detection in AWGN
clear; clc; close all;

%% 1. System Parameters
N_samples = 1e3;               % Signal samples per trial
N_trials  = 1e4;               % Number of Monte Carlo trials
snr_dB    = -10:2:15;          % SNR range in dB
snr_lin   = 10.^(snr_dB / 10); % SNR in linear scale

% Target Signal Definition (Rectangular Pulse)
s = ones(1, N_samples);        % Unit amplitude pulse
s_power = mean(abs(s).^2);     % Signal power

%% 2. Threshold Calculation for Fixed Pfa
target_Pfa = 1e-3;             % Desired Probability of False Alarm
% Threshold derived for Noise Power = 1: V_th = sqrt(-2 * sigma^2 * log(Pfa))
v_th = sqrt(-2 * log(target_Pfa)); 

%% 3. Monte Carlo Simulation
Pd_sim  = zeros(1, length(snr_dB));
Pfa_sim = zeros(1, length(snr_dB));

for i = 1:length(snr_dB)
    snr = snr_dB(i);
    detections  = 0;
    false_alarms = 0;
    
    for trial = 1:N_trials
        % Target Present Case: x = s + n
        x_target = awgn(s, snr, 'measured'); 
        
        % Target Absent Case (Noise Only): n ~ N(0, sigma^2)
        noise_power = s_power / snr_lin(i);
        noise_only  = sqrt(noise_power) * randn(1, N_samples);
        
        % Energy Detector / Amplitude Detector (Peak detection test)
        if max(x_target) > v_th * sqrt(noise_power)
            detections = detections + 1;
        end
        
        if max(noise_only) > v_th * sqrt(noise_power)
            false_alarms = false_alarms + 1;
        end
    end
    
    % Estimate Probabilities
    Pd_sim(i)  = detections / N_trials;
    Pfa_sim(i) = false_alarms / N_trials;
end

%% 4. Theoretical Pd Calculation (Match Filter / Coherent Receiver)
% Theoretical Pd = Q( Q^-1(Pfa) - sqrt(2 * SNR) )
Pd_theory = marcumq(sqrt(2 * snr_lin), sqrt(-2 * log(target_Pfa)));

%% 5. Plotting Results
figure;
plot(snr_dB, Pd_sim, 'ro-', 'LineWidth', 1.5, 'DisplayName', 'Simulated P_d');
hold on;
plot(snr_dB, Pd_theory, 'b--', 'LineWidth', 2, 'DisplayName', 'Theoretical P_d');
grid on;
xlabel('SNR (dB)');
ylabel('Probability of Detection (P_d)');
title(['Probability of Detection vs SNR (P_{fa} = ', num2str(target_Pfa), ')']);
legend('Location', 'Best');

% Receiver Operating Characteristic (ROC) Curve Generation
figure;
pfa_range = logspace(-4, 0, 100);
snr_eval  = [0, 5, 10]; % SNR values in dB for ROC

for k = 1:length(snr_eval)
    snr_curr = 10^(snr_eval(k)/10);
    pd_roc   = marcumq(sqrt(2 * snr_curr), sqrt(-2 * log(pfa_range)));
    semilogx(pfa_range, pd_roc, 'LineWidth', 1.5, ...
        'DisplayName', ['SNR = ', num2str(snr_eval(k)), ' dB']);
    hold on;
end

grid on;
xlabel('Probability of False Alarm (P_{fa})');
ylabel('Probability of Detection (P_d)');
title('Receiver Operating Characteristic (ROC) Curves');
legend('Location', 'Best');

