function y = HP_Filter(x)
%HP_FILTER2 Filters input x and returns output y.

% MATLAB Code
% Generated by MATLAB(R) 9.14 and DSP System Toolbox 9.16.
% Generated on: 05-May-2023 19:49:49

%#codegen

% To generate C/C++ code from this function use the codegen command. Type
% 'help codegen' for more information.

persistent Hd;

if isempty(Hd)
    
    % The following code was used to design the filter coefficients:
    % % Equiripple Highpass filter designed using the FIRPM function.
    %
    % % All frequency values are in Hz.
    % Fs = 24000;  % Sampling Frequency
    %
    % Fstop = 5000;            % Stopband Frequency
    % Fpass = 6000;            % Passband Frequency
    % Dstop = 0.0001;          % Stopband Attenuation
    % Dpass = 0.057501127785;  % Passband Ripple
    % dens  = 20;              % Density Factor
    %
    % % Calculate the order from the parameters using FIRPMORD.
    % [N, Fo, Ao, W] = firpmord([Fstop, Fpass]/(Fs/2), [0 1], [Dstop, Dpass]);
    %
    % % Calculate the coefficients using the FIRPM function.
    % b  = firpm(N, Fo, Ao, W, {dens});
    
    Hd = dsp.FIRFilter( ...
        'Numerator', [0.000630447178089792 -0.00400830363457713 ...
        0.0094327507415814 -0.0100793203383498 0.00172860794373274 ...
        0.00614040355487584 -0.00217596220606626 -0.0056100157487969 ...
        0.00179762524781396 0.00631585095156953 -0.00123940840335718 ...
        -0.00758959142805486 0.000379032838215427 0.00925025686244555 ...
        0.000934117357063215 -0.0111832848867292 -0.00290984017309027 ...
        0.0133256026199124 0.00576699818586685 -0.0155904415706014 ...
        -0.00980035877588581 0.0178699516151147 0.0154721365008409 ...
        -0.02006125684905 -0.0235790370473612 0.0220545858524501 ...
        0.0357901077315959 -0.023742856761068 -0.0564557575951256 ...
        0.0250286240090282 0.101658080163773 -0.0258320685727033 ...
        -0.316807211998383 0.526105051535348 -0.316807211998383 ...
        -0.0258320685727033 0.101658080163773 0.0250286240090282 ...
        -0.0564557575951256 -0.023742856761068 0.0357901077315959 ...
        0.0220545858524501 -0.0235790370473612 -0.02006125684905 ...
        0.0154721365008409 0.0178699516151147 -0.00980035877588581 ...
        -0.0155904415706014 0.00576699818586685 0.0133256026199124 ...
        -0.00290984017309027 -0.0111832848867292 0.000934117357063215 ...
        0.00925025686244555 0.000379032838215427 -0.00758959142805486 ...
        -0.00123940840335718 0.00631585095156953 0.00179762524781396 ...
        -0.0056100157487969 -0.00217596220606626 0.00614040355487584 ...
        0.00172860794373274 -0.0100793203383498 0.0094327507415814 ...
        -0.00400830363457713 0.000630447178089792]);
end

y = step(Hd,double(x));


% [EOF]
