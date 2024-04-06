max_length_y = 38089; 
max_length_n = 33623;
max_fs = 0;
sum_of_yes = 0;
sum_of_no = 0;
% DEFINE FULL PATH FOR SOUND FILES
% It should contain GoodYes, GoodNo and Random(for test)
% The program is going to generate the cut versions
fullpath = 'C:\Users\memre\OneDrive\Masaüstü\MSc Lectures\868H1-DSPL\Project\ProjectSounds';
%% Remove the sin wave and making them all the same length

for i=1:25 % THIS FOR YES FILES
    myfolder = 'GoodYes';
    myfilename= sprintf('y%i.wav',i);
    myfilename = fullfile(fullpath,myfolder,myfilename);
    [Y,Fs] = audioread(myfilename);  % Your file name
    cut_s = 0.5*Fs;
%      if  max_length < length(Y)
%          max_length = length(Y);

%          max_i = i;
%      end
    extend_arr = zeros(max_length_y-length(Y),1);
    Y = [Y ; extend_arr];
    
    savefilename= sprintf('cutversion_y%i.wav',i);
    savefilename = fullfile(fullpath,myfolder,savefilename);
    audiowrite(savefilename,Y(cut_s:end),Fs);   
    
end
for i=1:24 % THIS IS FOR NO FILES
    myfolder = 'GoodNo';
    myfilename= sprintf("n%i.wav",i);
    myfilename = fullfile(fullpath,myfolder,myfilename);
    [Y,Fs] = audioread(myfilename);  % Your file name
    cut_s = 0.5*Fs;
    extend_arr = zeros(max_length_n-length(Y),1);
    Y = [Y ; extend_arr];
    savefilename= sprintf('cutversion_n%i.wav',i);
    savefilename = fullfile(fullpath,myfolder,savefilename);
    audiowrite(savefilename,Y(cut_s:end),Fs);   
    
end

%% Calculating the mean power of the sound files by doing FFT
for i=1:25 % THIS FOR YES FFT FILES
    myfolder = 'GoodYes';
    myfilename= sprintf('cutversion_y%i.wav',i);
    myfilename = fullfile(fullpath,myfolder,myfilename);
    [Y,Fs] = audioread(myfilename);  % Your file name

    z=fft(Y,Fs);
    z_half_l = ceil(length(z)/2);
    z_half = z(1:z_half_l);
    sum_of_yes = sum_of_yes + (z_half.*conj(z_half));
end
    mean_yes = sum_of_yes/25;
    %subplot(2,1,1);
    %semilogy(mean_yes);
    %ylabel('|Y(f)^2|');
    %xlabel('Frequency(Hz)');
    %hold on;
    %ylim([0 10^5]);
    %xlim([0 12000]);
for i=1:24 % THIS FOR NO FFT FILES
    myfolder = 'GoodNo';
    myfilename= sprintf('cutversion_n%i.wav',i);
    myfilename = fullfile(fullpath,myfolder,myfilename);
    [Y,Fs] = audioread(myfilename);  % Your file name

    z=fft(Y,Fs);
    z_half_l = ceil(length(z)/2);
    z_half = z(1:z_half_l);
    sum_of_no = sum_of_no + (z_half.*conj(z_half));
end
    mean_no = sum_of_no/24;
    %semilogy(mean_no);
    %legend('Yes','No');
    
    %% DO FILTERING and find the ratios as well as bounderies
   
    sum_of_no_filtered_HP_FT = 0;
    sum_of_no_filtered_LP_FT = 0;
    sum_of_no_filtered_HP =0;
    sum_of_no_filtered_LP =0;

    upperboundry_NO=-1;
    lowerboundry_NO=-1;
    no_filtered_HP = zeros(24,1);
    no_filtered_LP = zeros(24,1);
    for i=1:24 % THIS FOR NO FFT FILES
     myfolder = 'GoodNo';
     myfilename= sprintf('cutversion_n%i.wav',i);
     myfilename = fullfile(fullpath,myfolder,myfilename);
     
     [Y,Fs] = audioread(myfilename);  % Your file name
     %hold on;
     filtered_response_HP = HP_Filter(Y);
     filtered_response_LP = LP_Filter(Y);

     %Do FFT to the filtered response of High-Pass Filter for NO files
      z=fft(filtered_response_HP,Fs);
      z_half_l = ceil(length(z)/2); %Calculate the first half of it
      z_half = z(1:z_half_l); %Take the first half of it
      sum_of_no_filtered_HP_FT = sum_of_no_filtered_HP_FT + (z_half.*conj(z_half)); %Accumulate the filtered output power
      
      sum_of_no_filtered_HP = 0;
      for k=1:length(filtered_response_HP) 
      sum_of_no_filtered_HP = sum_of_no_filtered_HP + filtered_response_HP(k)^2;
      no_filtered_HP(i) = no_filtered_HP(i) + filtered_response_HP(k)^2;
      end
     
      %Do FFT to the filtered response of Low-Pass Filter for NO files
      z=fft(filtered_response_LP,Fs);
      z_half_l = ceil(length(z)/2); %Calculate the first half of it
      z_half = z(1:z_half_l); %Take the first half of it
      sum_of_no_filtered_LP_FT = sum_of_no_filtered_LP_FT + (z_half.*conj(z_half)); %Accumulate the filtered output power
      
      sum_of_no_filtered_LP = 0;
      for k=1:length(filtered_response_LP)
      sum_of_no_filtered_LP = sum_of_no_filtered_LP + filtered_response_LP(k)^2;
      no_filtered_LP(i) = no_filtered_LP(i) + filtered_response_LP(k)^2;
      end

      if i == 1
          upperboundry_NO = no_filtered_LP(i)/no_filtered_HP(i);


      elseif (no_filtered_LP(i)/no_filtered_HP(i)) > upperboundry_NO

          upperboundry_NO = no_filtered_LP(i)/no_filtered_HP(i);

      end

      if i == 1
          lowerboundry_NO = no_filtered_LP(i)/no_filtered_HP(i);


      elseif (no_filtered_LP(i)/no_filtered_HP(i))<lowerboundry_NO

          lowerboundry_NO = no_filtered_LP(i)/no_filtered_HP(i);

      end

    end
    
    sum_of_yes_filtered_HP_FT = 0;
    sum_of_yes_filtered_LP_FT = 0;
    sum_of_yes_filtered_HP =0;
    sum_of_yes_filtered_LP =0;

    upperboundry_YES=-1;
    lowerboundry_YES=-1;
    yes_filtered_HP = zeros(25,1);
    yes_filtered_LP = zeros(25,1);
    for i=1:25 % THIS FOR YES FFT FILES
     myfolder = 'GoodYes';
     myfilename= sprintf('cutversion_y%i.wav',i);
     myfilename = fullfile(fullpath,myfolder,myfilename);
     [Y,Fs] = audioread(myfilename);  % Your file name
     %hold on;
     filtered_response_HP = HP_Filter(Y);
     filtered_response_LP = LP_Filter(Y);

     %Do FFT to the filtered response of High-Pass Filter
      z=fft(filtered_response_HP,Fs);
      z_half_l = ceil(length(z)/2); %Calculate the first half of it
      z_half = z(1:z_half_l); %Take the first half of it
      sum_of_yes_filtered_HP_FT = sum_of_yes_filtered_HP_FT + (z_half.*conj(z_half)); %Accumulate the filtered output power
        
      sum_of_yes_filtered_HP = 0;
      for k=1:length(filtered_response_HP)
      sum_of_yes_filtered_HP = sum_of_yes_filtered_HP + filtered_response_HP(k)^2;
      yes_filtered_HP(i) = yes_filtered_HP(i) + filtered_response_HP(k)^2;
      end
     
      %Do FFT to the filtered response of Low-Pass Filter
      z=fft(filtered_response_LP,Fs);
      z_half_l = ceil(length(z)/2); %Calculate the first half of it
      z_half = z(1:z_half_l); %Take the first half of it
      sum_of_yes_filtered_LP_FT = sum_of_yes_filtered_LP_FT + (z_half.*conj(z_half)); %Accumulate the filtered output power
      
      sum_of_yes_filtered_LP = 0;
      for k=1:length(filtered_response_LP)
      sum_of_yes_filtered_LP = sum_of_yes_filtered_LP + filtered_response_LP(k)^2; %Accumulate the filtered output power
      yes_filtered_LP(i) = yes_filtered_LP(i) + filtered_response_LP(k)^2;         %This part is to find the boundries
      end
      
      if (yes_filtered_LP(i)/yes_filtered_HP(i)) > upperboundry_YES

          upperboundry_YES = yes_filtered_LP(i)/yes_filtered_HP(i);

      end

      
      if i == 1
          lowerboundry_YES = yes_filtered_LP(i)/yes_filtered_HP(i);


      elseif (yes_filtered_LP(i)/yes_filtered_HP(i))<lowerboundry_YES

          lowerboundry_YES = yes_filtered_LP(i)/yes_filtered_HP(i);

      end
    end


     mean_no_filtered_HP = sum_of_no_filtered_HP_FT/24;
     mean_no_filtered_LP = sum_of_no_filtered_LP_FT/24;
     mean_yes_filtered_HP = sum_of_yes_filtered_HP_FT/25;
     mean_yes_filtered_LP = sum_of_no_filtered_LP_FT/25;
     %semilogy(mean_no_filtered_HP);
     %semilogy(mean_no_filtered_LP);
     %semilogy(mean_yes_filtered_HP);
     %semilogy(mean_yes_filtered_LP);
     ratio_of_NO = sum_of_no_filtered_LP/sum_of_no_filtered_HP;
     ratio_of_YES = sum_of_yes_filtered_LP/sum_of_yes_filtered_HP;
     %hold off;
     %subplot(2,1,2);
     %semilogy(ratio_of_NO);
     %semilogy(ratio_of_YES);
    
    
    %% Testing
    sum_of_HP = 0;
    sum_of_LP = 0;
for i=1:8 % THIS FOR YES FFT FILES
     myfolder = 'Random';
     myfilename= sprintf('r%i.wav',i);
     myfilename = fullfile(fullpath,myfolder,myfilename);
     [Y,Fs] = audioread(myfilename);  % Your file name
     Y = resample(Y,24000,Fs);

     filtered_response_HP = HP_Filter(Y);
     filtered_response_LP = LP_Filter(Y);

     sum_of_HP = 0;
     for k=1:length(filtered_response_HP)
      sum_of_HP = sum_of_HP + filtered_response_HP(k)^2;
     end
     sum_of_LP = 0;
     for k=1:length(filtered_response_LP)
      sum_of_LP = sum_of_LP + filtered_response_LP(k)^2;
     end
     
     input_ratio = (sum_of_LP)/(sum_of_HP);

     % CHECK the input whether it is yes

     if  ( input_ratio >= lowerboundry_YES ) && ( input_ratio <= upperboundry_YES )

         fprintf("YES is detected for input(%d)\n",i);


     elseif  ( input_ratio >= lowerboundry_NO ) && ( input_ratio <= upperboundry_NO )

         fprintf("NO is detected for input(%d)\n",i);
     
     else

        fprintf("Nothing is detected for input(%d)\n",i);
     end

end

%% Testing OTHERS the corrupted sound files

    sum_of_HP = 0;
    sum_of_LP = 0;
    myfolder = 'Others';
    %myfilename= sprintf('*.wav');
    myfilename = fullfile(fullpath,myfolder,'*.wav');
    myfilepath = dir(myfilename);
    fprintf("\n**The Corrupted Sounds are testing now !**\n");
for i=1:length(myfilepath) % THIS FOR YES FFT FILES

     myfilepath_name = myfilepath(i).name;
     myfilepath_2 = fullfile(fullpath,myfolder,myfilepath_name);
     [Y,Fs] = audioread(myfilepath_2);  % Your file name

    % Remove the sin wave
    cut_s = 0.5*Fs;
    extend_arr = zeros(max_length_y-length(Y),1);
    Y = [Y ; extend_arr];
    
    savefilename= sprintf('cutversion_%i.wav',i);
    savefilename = fullfile(fullpath,myfolder,savefilename);
    audiowrite(savefilename,Y(cut_s:end),Fs); 
    
    myfilename= sprintf('cutversion_%i.wav',i);
    myfilename = fullfile(fullpath,myfolder,myfilename);
    [Y,Fs] = audioread(myfilename);  % Your file name



     filtered_response_HP = HP_Filter(Y);
     filtered_response_LP = LP_Filter(Y);

     sum_of_HP = 0;
     for k=1:length(filtered_response_HP)
      sum_of_HP = sum_of_HP + filtered_response_HP(k)^2;
     end
     sum_of_LP = 0;
     for k=1:length(filtered_response_LP)
      sum_of_LP = sum_of_LP + filtered_response_LP(k)^2;
     end
     
     input_ratio = (sum_of_LP)/(sum_of_HP);

     % CHECK the input whether it is yes
     

     if  ( input_ratio >= lowerboundry_YES ) && ( input_ratio <= upperboundry_YES )

         fprintf("YES is detected for input(%s,%i)\n",myfilepath_name,i);


     elseif  ( input_ratio >= lowerboundry_NO ) && ( input_ratio <= upperboundry_NO )

         fprintf("NO is detected for input(%s,%i)\n",myfilepath_name,i);
     
     else

        fprintf("Nothing is detected for input(%s,%i)\n",myfilepath_name,i);
     end

end









