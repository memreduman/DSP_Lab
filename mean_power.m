max_length_y = 38089;
max_length_n = 33623;
max_fs = 0;
sum_of_yes = 0;
sum_of_no = 0;
for i=1:25 % THIS FOR YES FILES
    myfolder = 'C:\Users\memre\OneDrive\Masaüstü\Sussex MSc Lectures\868H1 - Digital Signal Processing Laboratory\Project\ProjectSounds\GoodYes';
    myfilename= sprintf('y%i.wav',i);
    myfilename = fullfile(myfolder,myfilename);
    [Y,Fs] = audioread(myfilename);  % Your file name
    cut_s = 0.5*Fs;
%      if  max_length < length(Y)
%          max_length = length(Y);
%          max_i = i;
%      end
    extend_arr = zeros(max_length_y-length(Y),1);
    Y = [Y ; extend_arr];
   
    savefilename= sprintf('cutversion_y%i.wav',i);
    savefilename = fullfile(myfolder,savefilename);
    audiowrite(savefilename,Y(cut_s:end),Fs);  
   
end
for i=1:24 % THIS IS FOR NO FILES
    myfolder = 'C:\Users\memre\OneDrive\Masaüstü\Sussex MSc Lectures\868H1 - Digital Signal Processing Laboratory\Project\ProjectSounds\GoodNo';
    myfilename= sprintf("n%i.wav",i);
    myfilename = fullfile(myfolder,myfilename);
    [Y,Fs] = audioread(myfilename);  % Your file name
    cut_s = 0.5*Fs;
    extend_arr = zeros(max_length_n-length(Y),1);
    Y = [Y ; extend_arr];
    savefilename= sprintf('cutversion_n%i.wav',i);
    savefilename = fullfile(myfolder,savefilename);
    audiowrite(savefilename,Y(cut_s:end),Fs);  
   
end
for i=1:25 % THIS FOR YES FFT FILES
    myfolder = 'C:\Users\memre\OneDrive\Masaüstü\Sussex MSc Lectures\868H1 - Digital Signal Processing Laboratory\Project\ProjectSounds\GoodYes';
    myfilename= sprintf('cutversion_y%i.wav',i);
    myfilename = fullfile(myfolder,myfilename);
    [Y,Fs] = audioread(myfilename);  % Your file name
    %half = ceil(length(Y)/2);
    %Y1 = Y(1:half);
    %sum_of_yes = sum_of_yes + Y;
    %sum_of_half_yes = sum_of_half_yes + Y1;
    z=fft(Y,Fs);
    z_half_l = ceil(length(z)/2);
    z_half = z(1:z_half_l);
    sum_of_yes = sum_of_yes + (z_half.*conj(z_half));
%   sum_of_yes = sum_of_yes + abs(z_half).^2;
end
    mean_yes = sum_of_yes/25;
    semilogy(mean_yes);
    ylabel('|Y(f)^2|');
    xlabel('Frequency(Hz)');
    hold on;
    ylim([0 10^5]);
    xlim([0 12000]);
for i=1:24 % THIS FOR NO FFT FILES
    myfolder = 'C:\Users\memre\OneDrive\Masaüstü\Sussex MSc Lectures\868H1 - Digital Signal Processing Laboratory\Project\ProjectSounds\GoodNo';
    myfilename= sprintf('cutversion_n%i.wav',i);
    myfilename = fullfile(myfolder,myfilename);
    [Y,Fs] = audioread(myfilename);  % Your file name
    %half = ceil(length(Y)/2);
    %Y1 = Y(1:half);
    %sum_of_yes = sum_of_yes + Y;
    %sum_of_half_yes = sum_of_half_yes + Y1;
    z=fft(Y,Fs);
    z_half_l = ceil(length(z)/2);
    z_half = z(1:z_half_l);
    sum_of_no = sum_of_no + (z_half.*conj(z_half));
%   sum_of_yes = sum_of_yes + abs(z_half).^2;
end
    mean_no = sum_of_no/24;
    semilogy(mean_no);
%    
%    for i=1:24 % THIS FOR NO FFT FILES
%     myfolder = 'C:\Users\memre\OneDrive\Masaüstü\Sussex MSc Lectures\868H1 - Digital Signal Processing Laboratory\Project\ProjectSounds\GoodNo';
%     myfilename= sprintf('cutversion_n%i.wav',i);
%     myfilename = fullfile(myfolder,myfilename);
%     [Y,Fs] = audioread(myfilename);  % Your file name
%     filtered_response = doFilter(Y);
%     z=fft(filtered_response,Fs);
%     z_half_l = ceil(length(z)/2);
%     z_half = z(1:z_half_l);
%     sum_of_no = sum_of_no + (z_half.*conj(z_half));
% %   sum_of_yes = sum_of_yes + abs(z_half).^2;
% end
%    mean_no = sum_of_no/24;
%    semilogy(mean_no);
%    legend('Yes','No','Filtered Response');