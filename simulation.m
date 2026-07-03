%% Szimulációs kisérletekhez

clc; clear; clf; close all

vk = {};
msdk = {};
drk = {};
ek = {};
maxek = {};
muek = {};
avk = {};
alfa_ok = {};
angle_av_ossz = {};
angle_std_ossz = {};
angle_zc_ossz = {};

kont = 1;

c1 = [255 82 51]./255;
c2 = [255 177 51]./255;
c3 = [64 234 43]./255;
c4 = [184 0 0]./255;
c5 = [51 255 235]./255;
c6 = [51 161 255]./255;
c7 = [104 51 255]./255;
c8 = [237 51 255]./255;
c9 = [255 51 137]./255;
c10 = [170 110 40]./255;
cl_colors = {c1, c2, c3, c4, c5, c6, c7, c8, c9, c10};
clear c1 c2 c3 c4 c5 c6 c7 c8 c9 c10

rng(1);

for g = 1:100
    clear A;
    hangyaszam=10; % ennyi reszecske
    lepes=96; % lepesszam (ido)
    
    szorzo = kont; % mozgás: x es y iranyu elmozdulas hossza (alapbol [-0.5, 0.5] kozt)
    N = .5; % sejetvonal + anyag alapú mitörténik faktor
        
    % Fordulás, sebesség és koordináta meghatározás
    for i = 1:hangyaszam
        theta = rand()*360;
        for j = 1:lepes
            cc = .2;
            if rand() > N
                theta_m = theta;
                theta = theta + (rand()-0.5) * 360;
            else
                theta = theta + (rand()-0.5) * 10;
            end
            sebesseg = abs(((rand()-0.75)*10) * szorzo);
            x = sebesseg * sind(theta);
            y = sebesseg * cosd(theta);    
            A(i,:,j) = [x, y];

        end
    end
    
    antRecords = cumtrapz(A,3); % poziciok megadasa elmozdulasok alapjan, [0 0]-rol indulnak 


%% Szimulált sejt útjának kirajzolása 
    % mycolor=rand(hangyaszam,3);
    % figure(1);
    % for i=1:5
    % plot(squeeze(antRecords(i,1,:)),squeeze(antRecords(i,2,:)),'.-', 'Color', cl_colors{i});
    % hold on
    % end
    % axis equal
    % xlabel('X')
    % ylabel('Y')
    % grid on
    % % title('Sejtek mozgása')
    % xlim([-150 150]);
    % ylim([-150 150]);
    % xticks(-150:50:150);
    % yticks(-150:50:150);
    % 
    % ax = gca;
    % ax.FontSize = 13;
    % ax.FontName = 'Times New Roman';
    % close all;

%% Sebesség, elmozulás számítás
    t1 = 15;
    n = lepes-2;
    perc = 0:t1:(n*t1);
    t  = (perc/60);
    for h = 1: hangyaszam
        X(:,h) = squeeze(antRecords(h,1,:));
        Y(:,h) = squeeze(antRecords(h,2,:));
    end

    megtettut_eddig_per_file(lepes,hangyaszam) = 0;
    for h = 1: hangyaszam
        megtett_ut_eddig = 0;
        megtett_ut = 0;
        X_jel = X(:,h);
        Y_jel = Y(:,h);
        for s =1:length(X)-1                     
                megtett_ut_most = (sqrt( (X_jel(s+1)-X_jel(s))^2 + (Y_jel(s+1)-Y_jel(s))^2 ));
                megtett_ut = megtett_ut + megtett_ut_most;
                megtett_ut_eddig(s) = megtett_ut;
                megtettut_eddig_per_file(s+1, h) = megtett_ut_eddig(s);
        end
    end

    time_interval = 15;
    antSpeed = squeeze(sqrt(sum(diff(antRecords, 1, 3).^2, 2))) / time_interval;
    antpos = squeeze(sqrt(antRecords(:,1,:).^2+antRecords(:,2,:).^2));
    
    maxelmozd = [];
    for i = 1:size(antpos, 1)
        maxelm = 0;
        for j = 1:size(antpos,2)
            elm = antpos(i,j);
            if maxelm < elm
                maxelm = elm;
            end
            maxelmozd(i, j) = maxelm;
            % maxe{end+1} = maxelm;
        end
    end
    

    antroad = megtettut_eddig_per_file';
     
    avgspeed=mean(antSpeed); %atlag
    avgpos=mean(antpos);
    avgroad=mean(antroad);
    stdspeed=std(antSpeed); %szoras
    stdpos=std(antpos);
    stdroad=std(antroad);

%% Sebesség - V + kirajzolás
    %figure(2);
    for i=1:hangyaszam
        %subplot(hangyaszam,1,i)
        %subplot(2,1,1)
%         plot(t, antSpeed(i,:),'.-', 'Color', mycolor(i,:));
%         title('Sebesség - 1 sejt')
%         ylabel('Sebesség')
%         xlabel('Idő [h]')
%         xlim([0 24]);
%         grid on
%         hold on;
        speed = antSpeed';
        vk{end+1} = speed(:,i);
    end
%         subplot(2,1,2)
%         errorbar(t,avgspeed,stdspeed, '.-');
%         title('Sebesség - összes sejtre')
%         ylabel('Sebesség')
%         xlabel('Idő [h]')
%         xlim([0 24]);
%         grid on

%% Átlag sebesség - AV + kirajzolás

    av_speed = mean(antSpeed, 2);
    av_speed1 = mean(av_speed);
    sd_speed = std(antSpeed, 0, 2);
    sd_speed1 = std(sd_speed);
    
%     figure(3);
    for i=1:hangyaszam
%         %subplot(hangyaszam,1,i)
%         subplot(2,1,1)
%         bar(i, av_speed(i,:), 'FaceColor', mycolor(i,:));
%         title('Átlag sebesség - 1 sejt')
%         ylabel('Sebesség')
%         grid on
%         hold on;
        avk{end+1} = av_speed(i,:);
    end
%         subplot(2,1,2)
%         bar(1,av_speed1);
%         title('Átlag sebesség - összes sejt')
%         ylabel('Sebesség')
%         grid on

%% Elmozdulás - D meghatározása és kirajzolás
%     figure(4);
%     t1 = 15;
%     n = lepes-1;
%     perc = 0:t1:(n*t1);
%     t  = (perc/60);
    for i=1:hangyaszam
%         subplot(2,1,1)
        %subplot(hangyaszam,1,i)
%         plot(t, antpos(i,:),'.-', 'Color', mycolor(i,:));
%         title('Elmozdulás - 1 sejt')
%         ylabel('Elmozdulás')
%         xlabel('Idő [h]')
%         xlim([0 24]);
%         grid on
%         hold on;
        elmozdulas = antpos';
        ek{end+1} = elmozdulas(:, i);
    end
%         subplot(2,1,2)
%         errorbar(t,avgpos,stdpos, '.-');
%         title('Elmozdulás - összes sejtre')
%         ylabel('Elmozdulás')
%         xlabel('Idő [h]')
%         xlim([0 24]);
%         grid on

%% Megtett út kirajzolás - TTD
%     figure(5);
%     t1 = 15;
%     n = lepes-1;
%     perc = 0:t1:(n*t1);
%     t  = (perc/60);
    for i=1:hangyaszam
%         subplot(2,1,1)
         %subplot(hangyaszam,1,i)
%         plot(t, antroad(i,:),'.-', 'Color', mycolor(i,:));
%         title('Megtett út eddig - 1 sejt')
%         ylabel('Megtett út')
%         xlabel('Idő [h]')
%         xlim([0 24]);
%         grid on
%         hold on;
        megtettuteddig = antroad';
        muek{end+1} = megtettuteddig(:, i);
    end
%         subplot(2,1,2)
%         errorbar(t,avgroad,stdroad, '.-');
%         title('Megtett út eddig - összes sejtre')
%         ylabel('Megtett út')
%         xlabel('Idő [h]')
%         xlim([0 24]);
%         grid on


%% Direkcionalitás ráta számolás - DR
    ep_dr = [];
    for i = 1:size(antroad,1)
        ep_dr(end+1) = antpos(i,end)/antroad(i,end);
    end
    ep_dr1 = mean(ep_dr);
    
%     figure(6);
    for i=1:hangyaszam
%         subplot(2,1,1)
        %subplot(hangyaszam,1,i)
%         bar(i, ep_dr(i), 'FaceColor', mycolor(i,:));
%         title('Directionality ratio - 1 sejt')
%         ylabel('DR')
%         grid on
%         hold on;
        drk{end+1} = ep_dr(i);
    end
%         subplot(2,1,2)
%         bar(1,ep_dr1);
%         title('Directionality ratio - összes sejtre')
%         ylabel('DR')
%         grid on


%% MSD számítás

    msd1 = NaN(max(lepes), max(lepes), max(hangyaszam));
    
    for j = 1:hangyaszam
        XY = antRecords(j,:,:);
        XY = permute(XY,[1 3 2]);
        XY = reshape(XY, [], size(XY,2),1)';
        x_sejtre = XY(:,1);
        y_sejtre = XY(:,2);
    
        for n = 1:lepes
            for i = 1:lepes-n
                d2 = (x_sejtre(i+n)-x_sejtre(i))^2 + (y_sejtre(i+n)-y_sejtre(i))^2;
                d2 = sqrt(d2);
                msd1(i,n, j) = d2;
            end
        end
    end
    msd_mean = {};
    msd_dev = {};
    for j = 1:hangyaszam
        msd_current = msd1(:,:,j);
        msd_current = reshape(permute(msd_current, [1,3,2]), size(msd_current, 3)*size(msd_current, 1), size(msd_current, 2))';
        
        darabteli = ~isnan(msd_current);
        darabteli = sum(darabteli, 2);
        
        msd_mean{end+1} = mean(msd_current, 2, 'omitnan');
        msd_dev{end+1}   = std(msd_current, 0, 2, 'omitnan') ./ darabteli;
    
    end
    
    ossz_msd1 = cell2mat(msd_mean);
    ossz_msd = mean(ossz_msd1,2);
    ossz_msd_std = std(ossz_msd1, 0, 2);
    
%     figure(7);
%     t1 = 15;
%     n = lepes-1;
%     perc = 0:t1:(n*t1);
%     t  = (perc/60);
    for i=1:hangyaszam
%         subplot(2,1,1)
        %subplot(hangyaszam,1,i)
%         plot(t, msd_mean{1,i},'.-', 'Color', mycolor(i,:));
%         title('MSD - 1 sejt')
%         ylabel('MSD')
%         xlabel('Idő [h]')
%         xlim([0 24]);
%         grid on
%         hold on;
        msdk{end+1} = msd_mean{1,i};
    end
%         subplot(2,1,2)
%         errorbar(t,ossz_msd,ossz_msd_std, '.-');
%         title('MSD - összes sejtre')
%         ylabel('MSD')
%         xlabel('Idő [h]')
%         xlim([0 24]);
%         grid on


%% Alfa - forgási szög számolás
    alfa_k(lepes,hangyaszam) = 0;
    for j = 1:hangyaszam
        X_jel = X(:,j);
        Y_jel = Y(:,j);
        alfa = 0;
        for n = 1:lepes-1          
            delta_x = X_jel(n+1) - X_jel(n);
            delta_y = Y_jel(n+1) - Y_jel(n);
            alfa(n) = atan2(delta_y, delta_x);
            % alfa(1) = abs(alfa(1)-alfa(1));
            alfa_k(n, j) =  rad2deg(alfa(n));
            if alfa_k(n) < 0
                alfa_k(n) = alfa_k(n) + 360;
            end
        end
        alfa_ok{end+1} = alfa_k(:,j);
    end

    % Átlagolt szög-irány (deg) - ATA
    angle_deg_avg = mean(alfa_k, 1, 'omitnan'); 
    angle_deg_std = std(alfa_k, 0, 1, 'omitnan');
    
    % Zero-crossing - TVZC detektálása – körkörös szögkülönbség alapján
    angle_zc = zeros(1, size(alfa_k, 2));
    
    for j = 1:size(alfa_k, 2)
        angles = alfa_k(:,j);
        dtheta = mod(diff(angles) + 180, 360) - 180;

        sign_change = sign(dtheta(1:end-1)) ~= sign(dtheta(2:end));
        valid = (sign(dtheta(1:end-1)) ~= 0) & (sign(dtheta(2:end)) ~= 0);
        
        angle_zc(j) = sum(sign_change & valid);
    end
    
    % Összesítve
    avg_angle_zc = mean(angle_zc);
    std_angle_zc = std(angle_zc);
    
    for i = 1:hangyaszam
        angle_av_ossz{end+1} = angle_deg_avg(i);
        angle_std_ossz{end+1} = angle_deg_std(i);
        angle_zc_ossz{end+1} = angle_zc(i);
    end




    % Max elmozdulas számítás és kirajzolás
    maxelmozd = maxelmozd';
    ossz_maxelm = mean(maxelmozd,2);
    ossz_maxelm_std = std(maxelmozd, 0, 2);
    
%     figure(8);
%     t1 = 15;
%     n = lepes-1;
%     perc = 0:t1:(n*t1);
%     t  = (perc/60);
    for i=1:hangyaszam
%         subplot(2,1,1)
        %subplot(hangyaszam,1,i)
%         plot(t, maxelmozd(:,i),'.-', 'Color', mycolor(i,:));
%         title('Maximális elmozdulás - 1 sejt')
%         ylabel('Max elmozd')
%         xlabel('Idő [h]')
%         xlim([0 24]);
%         grid on
%         hold on;
        maxek{end+1} = maxelmozd(:,i);
    end
%         subplot(2,1,2)
%         errorbar(t,ossz_maxelm,ossz_maxelm_std, '.-');
%         title('Maximális elmozdulás - összes sejtre')
%         ylabel('Max elmozd')
%         xlabel('Idő [h]')
%         xlim([0 24]);
%         grid on



    antStatistics = [mean(antSpeed,2),max(antSpeed,[],2),min(antSpeed,[],2)];
    clf; close all
end

% Kontroll paraméterek rendezése
vk = cell2mat(vk);
msdk = cell2mat(msdk);
drk = cell2mat(drk);
ek = cell2mat(ek);
maxek = cell2mat(maxek);
muek = cell2mat(muek);
avk = cell2mat(avk);
alfa_ok = cell2mat(alfa_ok);
angle_av_ossz = cell2mat(angle_av_ossz);
angle_std_ossz = cell2mat(angle_std_ossz);
angle_zc_ossz = cell2mat(angle_zc_ossz);


%% Kontroll gorbe allatti teruletenek kiszamolasa (AUC)
msd_atlag = mean(msdk,2, 'omitnan');
msd_atlag = msd_atlag(1:end-1,:);

Tk_e_a = trapz(mean(ek, 2, 'omitnan'));
Tk_msd_a = trapz(msd_atlag);
Tk_v_a = trapz(mean(vk, 2, 'omitnan'));
Tk_mue_a = trapz(mean(muek, 2, 'omitnan'));
Tk_maxe_a = trapz(mean(maxek, 2, 'omitnan'));
Tk_alf_a = trapz(mean(alfa_ok, 2, 'omitnan'));

Kossz_e = trapz(ek);
Kossz_msd = trapz(msdk(1:end-1,:));
Kossz_v = trapz(vk);
Kossz_mue = trapz(muek);
Kossz_maxe = trapz(maxek);
Kossz_av = avk;
Kossz_dr = drk;
Kossz_angleav = angle_av_ossz;
Kossz_anglestd = angle_std_ossz;
Kossz_anglezc = angle_zc_ossz;

puffnev = {};
MaxT_elmozd = [];
MinT_elmozd = [];
MaxT_msd = [];
MinT_msd = [];
MaxT_v = [];
MinT_v = [];
MaxT_mu = [];
MinT_mu = [];
MaxT_maxe = [];
MinT_maxe = [];
MaxT_dr = [];
MinT_dr = [];
MaxT_v_a = [];
MinT_v_a = [];
MaxT_alf = [];
MinT_alf = [];
MaxT_angleav = [];
MinT_angleav = [];
MaxT_anglestd = [];
MinT_anglestd = [];
MaxT_anglezc = [];
MinT_anglezc = [];



% Puffer latoterek osszehasonlitasa

for j = 1:size(msdk, 2)

    eak = mean(ek, 2, 'omitnan');
    max_e = max(ek(:,j),eak(:,1));
    max_e = max_e(~isnan(max_e));
    min_e = min(ek(:,j),eak(:,1));
    min_e = min_e(~isnan(min_e));
    MaxT_elmozd = [MaxT_elmozd trapz(max_e)];
    MinT_elmozd = [MinT_elmozd trapz(min_e)];

    msdak = mean(msdk, 2, 'omitnan');
    max_msd = max(msdk(:,j), msdak(:,1));
    max_msd = max_msd(~isnan(max_msd));
    min_msd = min(msdk(:,j),msdak(:,1));
    min_msd = min_msd(~isnan(min_msd));
    MaxT_msd = [MaxT_msd trapz(max_msd)];
    MinT_msd = [MinT_msd trapz(min_msd)];

    vak = mean(vk, 2, 'omitnan');
    max_v = max(vk(:,j),vak(:,1));
    max_v = max_v(~isnan(max_v));
    min_v = min(vk(:,j),vak(:,1));
    min_v = min_v(~isnan(min_v));
    MaxT_v = [MaxT_v trapz(max_v)];
    MinT_v = [MinT_v trapz(min_v)];

    mueak = mean(muek, 2, 'omitnan');
    max_mu = max(muek(:,j),mueak(:,1));
    max_mu = max_mu(~isnan(max_mu));
    min_mu = min(muek(:,j),mueak(:,1));
    min_mu = min_mu(~isnan(min_mu));
    MaxT_mu = [MaxT_mu trapz(max_mu)];
    MinT_mu = [MinT_mu trapz(min_mu)];

    maxeak = mean(maxek, 2, 'omitnan');
    max_maxe = max(maxek(:,j),maxeak(:,1));
    max_maxe = max_maxe(~isnan(max_maxe));
    min_maxe = min(maxek(:,j),maxeak(:,1));
    min_maxe = min_maxe(~isnan(min_maxe));
    MaxT_maxe = [MaxT_maxe trapz(max_maxe)];
    MinT_maxe = [MinT_maxe trapz(min_maxe)];   

    alfak = mean(alfa_ok, 2, 'omitnan');
    max_alf = max(alfa_ok(:,j),alfak(:,1));
    max_alf = max_alf(~isnan(max_alf));
    min_alf = min(alfa_ok(:,j),alfak(:,1));
    min_alf = min_alf(~isnan(min_alf));
    MaxT_alf = [MaxT_alf trapz(max_alf)];
    MinT_alf = [MinT_alf trapz(min_alf)]; 

    vao = mean(avk, 2, 'omitnan');
    MaxT_v_a = [MaxT_v_a max(avk(1,j),vao)];
    MinT_v_a = [MinT_v_a min(avk(1,j),vao)];

    dro = mean(drk, 2, 'omitnan');
    MaxT_dr = [MaxT_dr max(drk(1,j),dro)];
    MinT_dr = [MinT_dr min(drk(1,j),dro)];

    angleavo = mean(angle_av_ossz, 2, 'omitnan');
    MaxT_angleav = [MaxT_angleav max(angle_av_ossz(1,j),angleavo)];
    MinT_angleav = [MinT_angleav min(angle_av_ossz(1,j),angleavo)];

    anglestdo = mean(angle_std_ossz, 2, 'omitnan');
    MaxT_anglestd = [MaxT_anglestd max(angle_std_ossz(1,j),anglestdo)];
    MinT_anglestd = [MinT_anglestd min(angle_std_ossz(1,j),anglestdo)];

    anglezco = mean(angle_zc_ossz, 2, 'omitnan');
    MaxT_anglezc = [MaxT_anglezc max(angle_zc_ossz(1,j),anglezco)];
    MinT_anglezc = [MinT_anglezc min(angle_zc_ossz(1,j),anglezco)];
end

KontT_elmozd = [];
KontT_msd = [];
KontT_v = [];
KontT_mu = [];
KontT_maxe = [];
KontT_v_a = [];
KontT_dr = [];
KontT_alf = [];
KontT_angleav = [];
KontT_anglestd = [];
KontT_anglezc = [];

for i = 1:size(msdk,2)
    T_elm_ossz = [(Tk_e_a(1)-MinT_elmozd(i))*-1 MaxT_elmozd(i)-Tk_e_a(1)];
    KontT_elmozd = [KontT_elmozd; sum(T_elm_ossz)];
    T_msd_ossz = [(Tk_msd_a(1)-MinT_msd(i))*-1 MaxT_msd(i)-Tk_msd_a(1)];
    KontT_msd = [KontT_msd; sum(T_msd_ossz)];
    T_v_ossz = [(Tk_v_a(1)-MinT_v(i))*-1 MaxT_v(i)-Tk_v_a(1)];
    KontT_v = [KontT_v; sum(T_v_ossz)];
    T_mu_ossz = [(Tk_mue_a(1)-MinT_mu(i))*-1 MaxT_mu(i)-Tk_mue_a(1)];
    KontT_mu = [KontT_mu; sum(T_mu_ossz)];
    T_maxe_ossz = [(Tk_maxe_a(1)-MinT_maxe(i))*-1 MaxT_maxe(i)-Tk_maxe_a(1)];
    KontT_maxe = [KontT_maxe; sum(T_maxe_ossz)];
    T_v_a_ossz = [(vao(1)-MinT_v_a(i))*-1 MaxT_v_a(i)-vao(1)];
    KontT_v_a = [KontT_v_a; sum(T_v_a_ossz)];
    T_dr_ossz = [(dro(1)-MinT_dr(i))*-1 MaxT_dr(i)-dro(1)];
    KontT_dr = [KontT_dr; sum(T_dr_ossz)];
    T_alf_ossz = [(Tk_alf_a(1)-MinT_alf(i))*-1 MaxT_alf(i)-Tk_alf_a(1)];
    KontT_alf = [KontT_alf; sum(T_alf_ossz)];
    T_angleav_ossz = [(angleavo(1)-MinT_angleav(i))*-1 MaxT_angleav(i)-angleavo(1)];
    KontT_angleav = [KontT_angleav; sum(T_angleav_ossz)];
    T_anglestd_ossz = [(anglestdo(1)-MinT_anglestd(i))*-1 MaxT_anglestd(i)-anglestdo(1)];
    KontT_anglestd = [KontT_anglestd; sum(T_anglestd_ossz)];
    T_anglezc_ossz = [(anglezco(1)-MinT_anglezc(i))*-1 MaxT_anglezc(i)-anglezco(1)];
    KontT_anglezc = [KontT_anglezc; sum(T_anglezc_ossz)];

end

% SEM számolás
SEM_e = std(KontT_elmozd)/sqrt(length(KontT_elmozd));
ts_e = tinv([0.025  0.975],length(KontT_elmozd)-1);
thr_e = (mean(KontT_elmozd) + ts_e*SEM_e);

SEM_msd = std(KontT_msd)/sqrt(length(KontT_msd));
ts_msd = tinv([0.025  0.975],length(KontT_msd)-1);
thr_msd = mean(KontT_msd) + ts_msd*SEM_msd;

SEM_v = std(KontT_v)/sqrt(length(KontT_v));
ts_v = tinv([0.025  0.975],length(KontT_v)-1);
thr_v = mean(KontT_v) + ts_v*SEM_v;

SEM_mu = std(KontT_mu)/sqrt(length(KontT_mu));
ts_mu = tinv([0.025  0.975],length(KontT_mu)-1);
thr_mu = mean(KontT_mu) + ts_mu*SEM_mu;

SEM_maxe = std(KontT_maxe)/sqrt(length(KontT_maxe));
ts_maxe = tinv([0.025  0.975],length(KontT_maxe)-1);
thr_maxe = mean(KontT_maxe) + ts_maxe*SEM_maxe;

SEM_v_a = std(KontT_v_a)/sqrt(length(KontT_v_a));
ts_v_a = tinv([0.025  0.975],length(KontT_v_a)-1);
thr_v_a = mean(KontT_v_a) + ts_v_a*SEM_v_a;

SEM_dr = std(KontT_dr)/sqrt(length(KontT_dr));
ts_dr = tinv([0.025  0.975],length(KontT_dr)-1);
thr_dr = mean(KontT_dr) + ts_dr*SEM_dr;

SEM_alf = std(KontT_alf)/sqrt(length(KontT_alf));
ts_alf = tinv([0.025  0.975],length(KontT_alf)-1);
thr_alf = mean(KontT_alf) + ts_alf*SEM_alf;

SEM_angleav = std(KontT_angleav)/sqrt(length(KontT_angleav));
ts_angleav = tinv([0.025  0.975],length(KontT_angleav)-1);
thr_angleav = mean(KontT_angleav) + ts_angleav*SEM_angleav;

SEM_anglestd = std(KontT_anglestd)/sqrt(length(KontT_anglestd));
ts_anglestd = tinv([0.025  0.975],length(KontT_anglestd)-1);
thr_anglestd = mean(KontT_anglestd) + ts_anglestd*SEM_anglestd;

SEM_anglezc = std(KontT_anglezc)/sqrt(length(KontT_anglezc));
ts_anglezc = tinv([0.025  0.975],length(KontT_anglezc)-1);
thr_anglezc = mean(KontT_anglezc) + ts_anglezc*SEM_anglezc;

%% Kezelesek

v_o = {};
msd_o = {};
dr_o = {};
e_o = {};
maxe_o = {};
mue_o = {};
av_o = {};
alfa_o = {};
angleav_o = {};
anglestd_o = {};
anglezc_o = {};

% 8 darab kezelésre futtatjuk le
for caseNum = 1:8
    v_o = {}; msd_o = {}; dr_o = {}; e_o = {}; maxe_o = {}; mue_o = {};
    av_o = {}; alfa_o = {}; angleav_o = {}; anglestd_o = {}; anglezc_o = {};

    % Beállítások az esetnek megfelelően
    switch caseNum
        case 1 % Serkent, keveset forog
            kez = kont+0.005 : 0.005 : kont+1; 
            N_values = linspace(0.5, 0.95, 200);

        case 2 % Serkent, sokat forog
            kez = kont+0.01 : 0.01 : kont+3;
            N_values = linspace(0.5, 0.05, 300);

        case 3 % Gatol, keveset forog
            kez = 0.005 : 0.005 : kont;
            N_values = linspace(0.95, 0.5, 200);  

        case 4 % Gatol, sokat forog
            kez = 0.005 : 0.005 : kont;
            N_values = linspace(0.05, 0.5, 200);
    % end
    % 
    % switch caseNum
        case 5 % Serkent, N fix 0.5
            kez = kont+0.005:0.005:kont+1;
            N_values = 0.5 * ones(1, 200); % minden elemre 0.5

        case 6 % random csökken, N fix 0.5
            kez = 0.005:0.005:kont;
            N_values = 0.5 * ones(1, 200);

        case 7 % random fix 1, N növekszik 0.5-től
            kez = ones(1, 200); 
            N_values = linspace(0.95, 0.5, 200);

        case 8 % random fix 1, N csökken 0.5-től
            kez = ones(1, 200); 
            N_values = linspace(0.05, 0.5, 200);
    end
    
   
    kez_o{caseNum} = kez;         
    kez_all{caseNum} = kez;
    N_all{caseNum} = N_values;


    % --- Itt jön az eredeti belső for-ciklus ---
    for f = 1:size(kez,2)
        rng(f);
        
        v = {};
        msd = {};
        dr = {};
        e = {};
        maxe = {};
        alf = {};
        mue = {};
        av = {};
        angleav = {};
        anglestd = {};
        anglezc = {};

        for g = 1:20
            clear A;
            v_l = {};
            msd_l = {};
            dr_l = {};
            alf_l = {};
            e_l = {};
            maxe_l = {};
            mue_l = {};
            av_l = {};
            hangyaszam = 10; % ennyi reszecske
            lepes = 96; % lepesszam (ido)

            % Szorzó amivel számolunk
            szorzo = kez(f);

            % N kiszámítása az adott esetre
            N = N_values(f);

            theta_oa = [];
            for i = 1:hangyaszam
                theta_o = [];
                theta = 0;
                theta = rand()*360;
                for j = 1:lepes
                    sebesseg = [];
                    cc = .5;
                    if rand() > N
                        theta_m = theta;
                        theta = theta + (rand()-0.5) * 360;
                    else
                        theta = theta + (rand()-0.5) * 10;
                    end
                    theta_o(end+1) = theta;
                    sebesseg = abs(((rand()-0.75)*10) * szorzo);
                    x = sebesseg * sind(theta);
                    y = sebesseg * cosd(theta);    
                    A(i,:,j) = [x, y];
        
                end
                theta_oa = [theta_oa; theta_o];
            end
            
            antRecords = cumtrapz(A,3); % poziciok megadasa elmozdulasok alapjan, [0 0]-rol indulnak 
        
        %% Szimulált sejt útjának kirajzolása 
            % mycolor=rand(hangyaszam,3); %szinek
            % figure(1);
            % for i=1:5
            % plot(squeeze(antRecords(i,1,:)),squeeze(antRecords(i,2,:)),'.-', 'Color', cl_colors{i});
            % hold on
            % end
            % axis equal
            % xlabel('X')
            % ylabel('Y')
            % grid on
            % % title('Sejtek mozgása')
            % xlim([-150 150]);
            % ylim([-150 150]);
            % xticks(-150:50:150);
            % yticks(-150:50:150);
            % ax = gca;
            % ax.FontSize = 13;
            % ax.FontName = 'Times New Roman';
            %     close all;
        %% Sebesség, megtett út számítása
            t1 = 15;
            n = lepes-2;
            perc = 0:t1:(n*t1);
            t  = (perc/60);
            for h = 1: hangyaszam
                X(:,h) = squeeze(antRecords(h,1,:));
                Y(:,h) = squeeze(antRecords(h,2,:));
            end
        
            megtettut_eddig_per_file = zeros(lepes, hangyaszam);
            for h = 1: hangyaszam
                megtett_ut_eddig = 0;
                megtett_ut = 0;
                X_jel = X(:,h);
                Y_jel = Y(:,h);
                for s =1:length(X)-1                     
                        megtett_ut_most = (sqrt( (X_jel(s+1)-X_jel(s))^2 + (Y_jel(s+1)-Y_jel(s))^2 ));
                        megtett_ut = megtett_ut + megtett_ut_most;
                        megtett_ut_eddig(s) = megtett_ut;
                        megtettut_eddig_per_file(s+1, h) = megtett_ut_eddig(s);
                end
            end
        
            time_interval = 15;
            antSpeed = squeeze(sqrt(sum(diff(antRecords, 1, 3).^2, 2))) / time_interval;
            antpos = squeeze(sqrt(antRecords(:,1,:).^2+antRecords(:,2,:).^2));
            
            maxelmozd = [];
            for i = 1:size(antpos, 1)
                maxelm = 0;
                for j = 1:size(antpos,2)
                    elm = antpos(i,j);
                    if maxelm < elm
                        maxelm = elm;
                    end
                    maxelmozd(i, j) = maxelm;
                    % maxe{end+1} = maxelm;
                end
            end
            
            antroad = megtettut_eddig_per_file';
                 
            
            avgspeed=mean(antSpeed); %atlag
            avgpos=mean(antpos);
            avgroad=mean(antroad);
            stdspeed=std(antSpeed); %szoras
            stdpos=std(antpos);
            stdroad=std(antroad);
        
        %% Kirajzolás sebességre 
            %figure(2);
            for i=1:hangyaszam
                %subplot(hangyaszam,1,i)
                %subplot(2,1,1)
        %         plot(t, antSpeed(i,:),'.-', 'Color', mycolor(i,:));
        %         title('Sebesség - 1 sejt')
        %         ylabel('Sebesség')
        %         xlabel('Idő [h]')
        %         xlim([0 24]);
        %         grid on
        %         hold on;
                speed = antSpeed';
                v_l{end+1} = speed(:,i);
            end
        %         subplot(2,1,2)
        %         errorbar(t,avgspeed,stdspeed, '.-');
        %         title('Sebesség - összes sejtre')
        %         ylabel('Sebesség')
        %         xlabel('Idő [h]')
        %         xlim([0 24]);
        %         grid on
        v{end+1} = cell2mat(v_l);
        
        %% Átlag sebesség és kirajzolás
        
            av_speed = mean(antSpeed, 2);
            av_speed1 = mean(av_speed);
            sd_speed = std(antSpeed, 0, 2);
            sd_speed1 = std(sd_speed);
            
        %     figure(3);
            for i=1:hangyaszam
        %         %subplot(hangyaszam,1,i)
        %         subplot(2,1,1)
        %         bar(i, av_speed(i,:), 'FaceColor', mycolor(i,:));
        %         title('Átlag sebesség - 1 sejt')
        %         ylabel('Sebesség')
        %         grid on
        %         hold on;
                av_l{end+1} = av_speed(i,:);
            end
        %         subplot(2,1,2)
        %         bar(1,av_speed1);
        %         title('Átlag sebesség - összes sejt')
        %         ylabel('Sebesség')
        %         grid on
        av{end+1} = cell2mat(av_l);
    
        %% Elmozdulás kirajzolás
        %     figure(4);
        %     t1 = 15;
        %     n = lepes-1;
        %     perc = 0:t1:(n*t1);
        %     t  = (perc/60);
            for i=1:hangyaszam
        %         subplot(2,1,1)
                %subplot(hangyaszam,1,i)
        %         plot(t, antpos(i,:),'.-', 'Color', mycolor(i,:));
        %         title('Elmozdulás - 1 sejt')
        %         ylabel('Elmozdulás')
        %         xlabel('Idő [h]')
        %         xlim([0 24]);
        %         grid on
        %         hold on;
                elmozdulas = antpos';
                e_l{end+1} = elmozdulas(:, i);
            end
        %         subplot(2,1,2)
        %         errorbar(t,avgpos,stdpos, '.-');
        %         title('Elmozdulás - összes sejtre')
        %         ylabel('Elmozdulás')
        %         xlabel('Idő [h]')
        %         xlim([0 24]);
        %         grid on
        e{end+1} = cell2mat(e_l);
    
        %% Totál megtett út kirajzolása
        %     figure(5);
        %     t1 = 15;
        %     n = lepes-1;
        %     perc = 0:t1:(n*t1);
        %     t  = (perc/60);
            for i=1:hangyaszam
        %         subplot(2,1,1)
                 %subplot(hangyaszam,1,i)
        %         plot(t, antroad(i,:),'.-', 'Color', mycolor(i,:));
        %         title('Megtett út eddig - 1 sejt')
        %         ylabel('Megtett út')
        %         xlabel('Idő [h]')
        %         xlim([0 24]);
        %         grid on
        %         hold on;
                megtettuteddig = antroad';
                mue_l{end+1} = megtettuteddig(:, i);
            end
        %         subplot(2,1,2)
        %         errorbar(t,avgroad,stdroad, '.-');
        %         title('Megtett út eddig - összes sejtre')
        %         ylabel('Megtett út')
        %         xlabel('Idő [h]')
        %         xlim([0 24]);
        %         grid on
        mue{end+1} = cell2mat(mue_l);
    
        %% Direkcinalitás ráta - DR számítása
            ep_dr = [];
            for i = 1:hangyaszam
                e_jel = e_l{i};
                mue_jel = mue_l{i};
                ep_dr(end+1) = e_jel(end)/mue_jel(end);
            end
            ep_dr1 = mean(ep_dr);
    
        %% Alfa - forgási szög számolása
        alfa_t(lepes,hangyaszam) = 0;
        for j = 1:hangyaszam
            X_jel = X(:,j);
            Y_jel = Y(:,j);
            alfa = 0;
            for n = 1:lepes-1          
                delta_x = X_jel(n+1) - X_jel(n);
                delta_y = Y_jel(n+1) - Y_jel(n);
                alfa(n) = atan2(delta_y, delta_x);
                alfa_t(n, j) =  rad2deg(alfa(n));
            end
            alf_l{end+1} = alfa_t(:,j);
        end
        alf{end+1} = cell2mat(alf_l);
    
        % Átlagolt szög-irány (deg) - ATA
        angle_deg_avgt = mean(alfa_t, 1, 'omitnan'); 
        angle_deg_stdt = std(alfa_t, 0, 1, 'omitnan');
        anglestd{end+1} = angle_deg_stdt;
        angleav{end+1} = angle_deg_avgt;
        
        % Zero-crossing (TVZC) detektálása – körkörös szögkülönbségek alapján
        angle_zct = zeros(1, size(alfa_t, 2));
        
        for j = 1:size(alfa_t, 2)
            angles = alfa_t(:,j);
            dtheta = mod(diff(angles) + 180, 360) - 180;
            sign_change = sign(dtheta(1:end-1)) ~= sign(dtheta(2:end));
            valid = (sign(dtheta(1:end-1)) ~= 0) & (sign(dtheta(2:end)) ~= 0);
            
            angle_zct(j) = sum(sign_change & valid);
        end
        
        anglezc{end+1} = angle_zct;
        
        % Összesítve
        avg_angle_zct = mean(angle_zct);
        std_angle_zct = std(angle_zct);
    
    
    
        % DR kirajzolása
        %     figure(6);
            for i=1:hangyaszam
        %         subplot(2,1,1)
                %subplot(hangyaszam,1,i)
        %         bar(i, ep_dr(i), 'FaceColor', mycolor(i,:));
        %         title('Directionality ratio - 1 sejt')
        %         ylabel('DR')
        %         grid on
        %         hold on;
                dr_l{end+1} = ep_dr(i);
            end
        %         subplot(2,1,2)
        %         bar(1,ep_dr1);
        %         title('Directionality ratio - összes sejtre')
        %         ylabel('DR')
        %         grid on
        dr{end+1} = cell2mat(dr_l);
        
        %% MSD számolás és kirajzolás
        
            msd1 = NaN(max(lepes), max(lepes), max(hangyaszam));
            
            for j = 1:hangyaszam
                XY = antRecords(j,:,:);
                XY = permute(XY,[1 3 2]);
                XY = reshape(XY, [], size(XY,2),1)';
                x_sejtre = XY(:,1);
                y_sejtre = XY(:,2);
            
                for n = 1:lepes
                    for i = 1:lepes-n
                        d2 = (x_sejtre(i+n)-x_sejtre(i))^2 + (y_sejtre(i+n)-y_sejtre(i))^2;
                        d2 = sqrt(d2);
                        msd1(i,n, j) = d2;
                    end
                end
            end
            msd_mean = {};
            msd_dev = {};
            for j = 1:hangyaszam
                msd_current = msd1(:,:,j);
                msd_current = reshape(permute(msd_current, [1,3,2]), size(msd_current, 3)*size(msd_current, 1), size(msd_current, 2))';
                
                darabteli = ~isnan(msd_current);
                darabteli = sum(darabteli, 2);
                
                msd_mean{end+1} = mean(msd_current, 2, 'omitnan');
                msd_dev{end+1}   = std(msd_current, 0, 2, 'omitnan') ./ darabteli;
            
            end
            
            ossz_msd1 = cell2mat(msd_mean);
            ossz_msd = mean(ossz_msd1,2);
            ossz_msd_std = std(ossz_msd1, 0, 2);
            
        %     figure(7);
        %     t1 = 15;
        %     n = lepes-1;
        %     perc = 0:t1:(n*t1);
        %     t  = (perc/60);
            for i=1:hangyaszam
        %         subplot(2,1,1)
                %subplot(hangyaszam,1,i)
        %         plot(t, msd_mean{1,i},'.-', 'Color', mycolor(i,:));
        %         title('MSD - 1 sejt')
        %         ylabel('MSD')
        %         xlabel('Idő [h]')
        %         xlim([0 24]);
        %         grid on
        %         hold on;
                msd_l{end+1} = msd_mean{1,i};
            end
        %         subplot(2,1,2)
        %         errorbar(t,ossz_msd,ossz_msd_std, '.-');
        %         title('MSD - összes sejtre')
        %         ylabel('MSD')
        %         xlabel('Idő [h]')
        %         xlim([0 24]);
        %         grid on
        msd{end+1} = cell2mat(msd_l);
    
        %% Max elmozdulas - MaxD és kirajzolás
            maxelmozd = maxelmozd';
            ossz_maxelm = mean(maxelmozd,2);
            ossz_maxelm_std = std(maxelmozd, 0, 2);
            
        %     figure(8);
        %     t1 = 15;
        %     n = lepes-1;
        %     perc = 0:t1:(n*t1);
        %     t  = (perc/60);
            for i=1:hangyaszam
        %         subplot(2,1,1)
                %subplot(hangyaszam,1,i)
        %         plot(t, maxelmozd(:,i),'.-', 'Color', mycolor(i,:));
        %         title('Maximális elmozdulás - 1 sejt')
        %         ylabel('Max elmozd')
        %         xlabel('Idő [h]')
        %         xlim([0 24]);
        %         grid on
        %         hold on;
                maxe_l{end+1} = maxelmozd(:,i);
            end
        %         subplot(2,1,2)
        %         errorbar(t,ossz_maxelm,ossz_maxelm_std, '.-');
        %         title('Maximális elmozdulás - összes sejtre')
        %         ylabel('Max elmozd')
        %         xlabel('Idő [h]')
        %         xlim([0 24]);
        %         grid on
        
        maxe{end+1} = cell2mat(maxe_l);
        
        
            antStatistics = [mean(antSpeed,2),max(antSpeed,[],2),min(antSpeed,[],2)];
            clf; close all
        end
        v_o{end+1} = v;
        msd_o{end+1} = msd;
        dr_o{end+1} = dr;
        e_o{end+1} = e;
        maxe_o{end+1} = maxe;
        mue_o{end+1} = mue;
        av_o{end+1} = av; 
        alfa_o{end+1} = alf;
        angleav_o{end+1} = angleav;
        anglestd_o{end+1} = anglestd;
        anglezc_o{end+1} = anglezc;
    end
    v_all{caseNum} = v_o;
    msd_all{caseNum} = msd_o;
    dr_all{caseNum} = dr_o;
    e_all{caseNum} = e_o;
    maxe_all{caseNum} = maxe_o;
    mue_all{caseNum} = mue_o;
    av_all{caseNum} = av_o;
    alfa_all{caseNum} = alfa_o;
    angleav_all{caseNum} = angleav_o;
    anglestd_all{caseNum} = anglestd_o;
    anglezc_all{caseNum} = anglezc_o;
end



%% Kezelesek és kontroll atlag osszehasonlitasa (kezeles AUC es puffer AUC)

for caseNum = 1:7
    kez = kez_all{caseNum};
    msd_o = msd_all{caseNum};
    dr_o = dr_all{caseNum};
    e_o = e_all{caseNum};
    maxe_o = maxe_all{caseNum};
    mue_o = mue_all{caseNum};
    av_o = av_all{caseNum};
    v_o = v_all{caseNum};
    alfa_o = alfa_all{caseNum};
    angleav_o  = angleav_all{caseNum};
    anglestd_o = anglestd_all{caseNum};
    anglezc_o  = anglezc_all{caseNum};

    MaxT_elmozd = [];
    MinT_elmozd = [];
    MaxT_msd = [];
    MinT_msd = [];
    MaxT_v = [];
    MinT_v = [];
    MaxT_v_a = [];
    MinT_v_a = [];
    MaxT_mu = [];
    MinT_mu = [];
    MaxT_maxe = [];
    MinT_maxe = [];
    MaxT_dr = [];
    MinT_dr = [];
    MaxT_alf = [];
    MinT_alf = [];
    MaxT_angleav = [];
    MinT_angleav = [];
    MaxT_anglestd = [];
    MinT_anglestd = [];
    MaxT_anglezc = [];
    MinT_anglezc = [];
    
    T_o_dr = {};
    T_o_e = {};
    T_o_maxe = {};
    T_o_msd = {};
    T_o_mu = {};
    T_o_v = {};
    T_o_av = {};
    T_o_alf = {};
    T_o_angleav = {};
    T_o_anglestd = {};
    T_o_anglezc = {};
    
    for j = 1:size(msd_o, 2)
        jelenkez = kez(j);
        T_i_dr = {};
        T_i_e = {};
        T_i_maxe = {};
        T_i_msd = {};
        T_i_mu = {};
        T_i_v = {};
        T_i_av = {};
        T_i_alf = {};
        T_i_angleav = {};
        T_i_anglestd = {};
        T_i_anglezc = {};
        for k = 1:size(msd_o{1,j}, 2)
            jelen = msd_o{1,j};
            T_elmozd = [];
            T_msd = [];
            T_v = [];
            T_v_a = [];
            T_mu = [];
            T_maxe = [];
            T_dr = []; 
            T_alf = [];
            T_angleav = []; 
            T_anglestd = [];
            T_anglezc = [];
            for g = 1:size(jelen{1,k}, 2)
                eo = e_o{1,j};
                el = eo{1,k};
                max_e = max(eak(:,1),el(:,g));
                max_e = max_e(~isnan(max_e));
                min_e = min(eak(:,1),el(:,g));
                min_e = min_e(~isnan(min_e));
                MaxT_elmozd = [MaxT_elmozd trapz(max_e)];
                MinT_elmozd = [MinT_elmozd trapz(min_e)];
            
                T_elm_ossz = [(Tk_e_a-MinT_elmozd(end))*-1 MaxT_elmozd(end)-Tk_e_a];
                T_elmozd = [T_elmozd sum(T_elm_ossz)];
    
                alfo = alfa_o{1,j};
                alfl = alfo{1,k};
                max_alf = max(alfak(:,1),alfl(:,g));
                max_alf = max_alf(~isnan(max_alf));
                min_alf = min(alfak(:,1),alfl(:,g));
                min_alf = min_alf(~isnan(min_alf));
                MaxT_alf = [MaxT_alf trapz(max_alf)];
                MinT_alf = [MinT_alf trapz(min_alf)];
            
                T_alf_ossz = [(Tk_alf_a-MinT_alf(end))*-1 MaxT_alf(end)-Tk_alf_a];
                T_alf = [T_alf sum(T_alf_ossz)];
                    
                msdo = msd_o{1,j};
                msdl = msdo{1,k};
                max_msd = max(msdak(:,1),msdl(:,g));
                max_msd = max_msd(~isnan(max_msd));
                min_msd = min(msdak(:,1),msdl(:,g));
                min_msd = min_msd(~isnan(min_msd));
                MaxT_msd = [MaxT_msd trapz(max_msd)];
                MinT_msd = [MinT_msd trapz(min_msd)];
            
                T_msd_ossz = [(Tk_msd_a-MinT_msd(end))*-1 MaxT_msd(end)-Tk_msd_a];
                T_msd = [T_msd sum(T_msd_ossz)];
            
                vo = v_o{1,j};
                vl = vo{1,k};
                max_v = max(vak(:,1),vl(:,g));
                max_v = max_v(~isnan(max_v));
                min_v = min(vak(:,1),vl(:,g));
                min_v = min_v(~isnan(min_v));
                MaxT_v = [MaxT_v trapz(max_v)];
                MinT_v = [MinT_v trapz(min_v)];
            
                T_v_ossz = [(Tk_v_a-MinT_v(end))*-1 MaxT_v(end)-Tk_v_a];
                T_v = [T_v sum(T_v_ossz)];
            
                muo = mue_o{1,j};
                mul = muo{1,k};
                max_mu = max(mueak(:,1),mul(:,g));
                max_mu = max_mu(~isnan(max_mu));
                min_mu = min(mueak(:,1),mul(:,g));
                min_mu = min_mu(~isnan(min_mu));
                MaxT_mu = [MaxT_mu trapz(max_mu)];
                MinT_mu = [MinT_mu trapz(min_mu)];
            
                T_mu_ossz = [(Tk_mue_a-MinT_mu(end))*-1 MaxT_mu(end)-Tk_mue_a];
                T_mu = [T_mu sum(T_mu_ossz)];
            
                maxeo = maxe_o{1,j};
                maxel = maxeo{1,k};
                max_maxe = max(maxeak(:,1),maxel(:,g));
                max_maxe = max_maxe(~isnan(max_maxe));
                min_maxe = min(maxeak(:,1),maxel(:,g));
                min_maxe = min_maxe(~isnan(min_maxe));
                MaxT_maxe = [MaxT_maxe trapz(max_maxe)];
                MinT_maxe = [MinT_maxe trapz(min_maxe)];
            
                T_maxe_ossz = [(Tk_maxe_a-MinT_maxe(end))*-1 MaxT_maxe(end)-Tk_maxe_a];
                T_maxe = [T_maxe sum(T_maxe_ossz)];
            
                avak = mean(avk,2);
                aveo = av_o{1,j};
                avl = aveo{1,k};
                max_v_a = max(avak,avl(1,g));
                min_v_a = min(avak,avl(1,g));
                MaxT_v_a = [MaxT_v_a max_v_a];
                MinT_v_a = [MinT_v_a min_v_a];
            
                T_v_a_ossz = [(avak-MinT_v_a(end))*-1 MaxT_v_a(end)-avak];
                T_v_a = [T_v_a sum(T_v_a_ossz)];
        
                drak = mean(drk,2);
                dreo = dr_o{1,j};
                drl = dreo{1,k};
                max_dr = max(drak,drl(1,g));
                min_dr = min(drak,drl(1,g));
                MaxT_dr = [MaxT_dr max_dr];
                MinT_dr = [MinT_dr min_dr];
            
                T_dr_ossz = [(drak-MinT_dr(end))*-1 MaxT_dr(end)-drak];
                T_dr = [T_dr sum(T_dr_ossz)];
    
                angleavak = mean(angle_av_ossz,2);
                angleaveo = angleav_o{1,j};
                angleavl = angleaveo{1,k};
                max_angleav = max(angleavak,angleavl(1,g));
                min_angleav = min(angleavak,angleavl(1,g));
                MaxT_angleav = [MaxT_angleav max_angleav];
                MinT_angleav = [MinT_angleav min_angleav];
            
                T_angleav_ossz = [(angleavak-MinT_angleav(end))*-1 MaxT_angleav(end)-angleavak];
                T_angleav = [T_angleav sum(T_angleav_ossz)];
    
                anglestdak = mean(angle_std_ossz,2);
                anglestdeo = anglestd_o{1,j};
                anglestdl = anglestdeo{1,k};
                max_anglestd = max(anglestdak,anglestdl(1,g));
                min_anglestd = min(anglestdak,anglestdl(1,g));
                MaxT_anglestd = [MaxT_anglestd max_anglestd];
                MinT_anglestd = [MinT_anglestd min_anglestd];
            
                T_anglestd_ossz = [(anglestdak-MinT_anglestd(end))*-1 MaxT_anglestd(end)-anglestdak];
                T_anglestd = [T_anglestd sum(T_anglestd_ossz)];
    
                anglezcak = mean(angle_zc_ossz,2);
                anglezceo = anglezc_o{1,j};
                anglezcl = anglezceo{1,k};
                max_anglezc = max(anglezcak,anglezcl(1,g));
                min_anglezc = min(anglezcak,anglezcl(1,g));
                MaxT_anglezc = [MaxT_anglezc max_anglezc];
                MinT_anglezc = [MinT_anglezc min_anglezc];
            
                T_anglezc_ossz = [(anglezcak-MinT_anglezc(end))*-1 MaxT_anglezc(end)-anglezcak];
                T_anglezc = [T_anglezc sum(T_anglezc_ossz)];
            end
            T_i_dr{end+1} = T_dr;
            T_i_e{end+1} = T_elmozd;
            T_i_maxe{end+1} = T_maxe;
            T_i_msd{end+1} = T_msd;
            T_i_mu{end+1} = T_mu;
            T_i_v{end+1} = T_v;
            T_i_av{end+1} = T_v_a;
            T_i_alf{end+1} = T_alf;
            T_i_angleav{end+1} = T_angleav;
            T_i_anglestd{end+1} = T_anglestd;
            T_i_anglezc{end+1} = T_anglezc;
        end
        T_o_dr{end+1} = T_i_dr;
        T_o_e{end+1} = T_i_e;
        T_o_maxe{end+1} = T_i_maxe;
        T_o_msd{end+1} = T_i_msd;
        T_o_mu{end+1} = T_i_mu;
        T_o_v{end+1} = T_i_v;
        T_o_av{end+1} = T_i_av;
        T_o_alf{end+1} = T_i_alf;
        T_o_angleav{end+1} = T_i_angleav;
        T_o_anglestd{end+1} = T_i_anglestd;
        T_o_anglezc{end+1} = T_i_anglezc;
    end
    
    dr_oa = {};
    for i = 1: size(dr_o,2)
        dr_jel = dr_o{i};
        dr_om = [];
        for j = 1: size(dr_jel,2)
            dr_om(end+1) = mean(dr_jel{j});
        end
        dr_oa{end+1} = mean(dr_om);
    end
    
  
    %% Annova számolása
    
    p_o_vs = {};
    p_o_msd = {};
    p_o_mu = {};
    p_o_v = {};
    p_o_av = {};
    p_o_maxe = {};
    p_o_e = {};
    p_o_dr = {};
    p_o_alf = {};
    p_o_angleav = {};
    p_o_anglestd = {};
    p_o_anglezc = {};

    for j = 1:size(T_o_msd,2)
        p_vs = {};
        p_msd = {};
        p_mu = {};
        p_v = {};
        p_av = {};
        p_maxe = {};
        p_e = {};
        p_dr = {};
        p_alf = {};
        p_angleav = {};
        p_anglestd = {};
        p_anglezc = {};
        for h = 1:size(T_o_msd{1,j},2)
            p_vs{end+1} = num2str(kez(1,j)/kont);
            p_vs2 = {'Kontroll' num2str(kez(1,j))};
            T_o_dr_j = T_o_dr{j};
            T_o_e_j = T_o_e{j};
            T_o_maxe_j = T_o_maxe{j};
            T_o_msd_j = T_o_msd{j};
            T_o_mu_j = T_o_mu{j};
            T_o_v_j = T_o_v{j};
            T_o_av_j = T_o_av{j};
            T_o_alf_j = T_o_alf{j};
            T_o_angleav_j = T_o_angleav{j};
            T_o_anglestd_j = T_o_anglestd{j};
            T_o_anglezc_j = T_o_anglezc{j};
            T_o_dr_ideig = {T_o_dr_j{h}' KontT_dr};
            T_o_e_ideig = {T_o_e_j{h}' KontT_elmozd};
            T_o_maxe_ideig = {T_o_maxe_j{h}' KontT_maxe};
            T_o_msd_ideig = {T_o_msd_j{h}' KontT_msd};
            T_o_mu_ideig = {T_o_mu_j{h}' KontT_mu};
            T_o_v_ideig = {T_o_v_j{h}' KontT_v};
            T_o_av_ideig = {T_o_av_j{h}' KontT_v_a};
            T_o_alf_ideig = {T_o_alf_j{h}' KontT_alf};
            T_o_angleav_ideig = {T_o_angleav_j{h}' KontT_angleav};
            T_o_anglestd_ideig = {T_o_anglestd_j{h}' KontT_anglestd};
            T_o_anglezc_ideig = {T_o_anglezc_j{h}' KontT_anglezc};

            T_o_dr_ideig = padcat(T_o_dr_ideig{:});
            T_o_e_ideig = padcat(T_o_e_ideig{:});
            T_o_maxe_ideig = padcat(T_o_maxe_ideig{:});
            T_o_msd_ideig = padcat(T_o_msd_ideig{:});
            T_o_mu_ideig = padcat(T_o_mu_ideig{:});
            T_o_v_ideig = padcat(T_o_v_ideig{:});
            T_o_av_ideig = padcat(T_o_av_ideig{:});
            T_o_alf_ideig = padcat(T_o_alf_ideig{:});
            T_o_angleav_ideig = padcat(T_o_angleav_ideig{:});
            T_o_anglestd_ideig = padcat(T_o_anglestd_ideig{:});
            T_o_anglezc_ideig = padcat(T_o_anglezc_ideig{:});
            if anova1(T_o_dr_ideig, p_vs2, 'off') < 0.0001          % one way anova DR; p < 0.0001
                p_dr{end+1} = num2str(kez(1,j)/kont);
            else
                p_dr{end+1} = 'hamis';
            end
            if anova1(T_o_alf_ideig, p_vs2, 'off') < 0.0001          % one way anova Alfa; p < 0.0001
                p_alf{end+1} = num2str(kez(1,j)/kont);
            else
                p_alf{end+1} = 'hamis';
            end
            if anova1(T_o_e_ideig, p_vs2, 'off') < 0.0001           %  one way anova Elmozd; p < 0.0001
                p_e{end+1} = num2str(kez(1,j)/kont);
            else
                p_e{end+1} = 'hamis';
            end
            if anova1(T_o_maxe_ideig, p_vs2, 'off') < 0.0001       %  one way anova Maxelm; p < 0.0001
                p_maxe{end+1} = num2str(kez(1,j)/kont);
            else
                p_maxe{end+1} = 'hamis';
            end
            if anova1(T_o_msd_ideig, p_vs2, 'off') < 0.0001        %  one way anova MSD; p < 0.0001
                p_msd{end+1} = num2str(kez(1,j)/kont);
            else
                p_msd{end+1} = 'hamis';
            end
            if anova1(T_o_mu_ideig, p_vs2, 'off') < 0.0001        %   one way anova Megtettut; p < 0.0001
                p_mu{end+1} = num2str(kez(1,j)/kont);
            else
                p_mu{end+1} = 'hamis';
            end
            if anova1(T_o_v_ideig, p_vs2, 'off') < 0.0001         %   one way anova Sebesseg; p < 0.0001
                p_v{end+1} = num2str(kez(1,j)/kont);
            else
                p_v{end+1} = 'hamis';
            end
            if anova1(T_o_av_ideig, p_vs2, 'off') < 0.0001        %   one way anova Atlag sebesseg; p < 0.0001
                p_av{end+1} = num2str(kez(1,j)/kont);
            else
                p_av{end+1} = 'hamis';
            end
            if anova1(T_o_angleav_ideig, p_vs2, 'off') < 0.0001        %   one way anova Atlag sebesseg; p < 0.0001
                p_angleav{end+1} = num2str(kez(1,j)/kont);
            else
                p_angleav{end+1} = 'hamis';
            end
            if anova1(T_o_anglestd_ideig, p_vs2, 'off') < 0.0001        %   one way anova Atlag sebesseg; p < 0.0001
                p_anglestd{end+1} = num2str(kez(1,j)/kont);
            else
                p_anglestd{end+1} = 'hamis';
            end
            if anova1(T_o_anglezc_ideig, p_vs2, 'off') < 0.0001        %   one way anova Atlag sebesseg; p < 0.0001
                p_anglezc{end+1} = num2str(kez(1,j)/kont);
            else
                p_anglezc{end+1} = 'hamis';
            end
        end
        p_o_vs{end+1} = p_vs;
        p_o_msd{end+1} = p_msd;
        p_o_mu{end+1} = p_mu;
        p_o_v{end+1} = p_v;
        p_o_av{end+1} = p_av;
        p_o_maxe{end+1} = p_maxe;
        p_o_e{end+1} = p_e;
        p_o_dr{end+1} = p_dr;
        p_o_alf{end+1} = p_alf;
        p_o_angleav{end+1} = p_angleav;
        p_o_anglestd{end+1} = p_anglestd;
        p_o_anglezc{end+1} = p_anglezc;
    

        %% Kirajzolja a különböző kezelések melletti szignifikáns eltéréseket - minden egyes paraméterre
        latoter = size(T_o_msd{1,j},2);
        n_msd = latoter-sum(strcmp(p_o_msd{j}, 'hamis'));
        figure(1)
        colorIndex = round((n_msd / 20) * 255);
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; 

        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        
        title('MSD', 'FontName', 'Times New Roman', 'FontSize', 18)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off  
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    
        n_mu = latoter-sum(strcmp(p_o_mu{j}, 'hamis'));
        figure(2)
        colorIndex = round( (n_mu / 20) * 255 ); 
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; 
        
        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        title('Megtett út', 'FontName', 'Times New Roman', 'FontSize', 16)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off  
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    
        n_v = latoter-sum(strcmp(p_o_v{j}, 'hamis'));
        figure(3)
        colorIndex = round( (n_v / 20) * 255 );  % 0..255 index
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; % RGB
        
        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        
        title('Sebesség', 'FontName', 'Times New Roman', 'FontSize', 16)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off  
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    
        n_av = latoter-sum(strcmp(p_o_av{j}, 'hamis'));
        figure(4)
        colorIndex = round( (n_av / 20) * 255 );  % 0..255 index
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; % RGB
        
        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        
        title('Átlag sebesség', 'FontName', 'Times New Roman', 'FontSize', 16)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off 
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    
        n_maxe = latoter-sum(strcmp(p_o_maxe{j}, 'hamis'));
        figure(5)
        colorIndex = round( (n_maxe / 20) * 255 );  % 0..255 index
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; % RGB
        
        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        
        title('Maximális elmozdulás', 'FontName', 'Times New Roman', 'FontSize', 16)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off  
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    
        n_e = latoter-sum(strcmp(p_o_e{j}, 'hamis'));
        figure(6)
        colorIndex = round( (n_e / 20) * 255 );  % 0..255 index
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; % RGB
        
        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        
        title('Elmozdulás', 'FontName', 'Times New Roman', 'FontSize', 16)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off 
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    
        n_dr = latoter-sum(strcmp(p_o_dr{j}, 'hamis'));
        figure(7)
        colorIndex = round( (n_dr / 20) * 255 );  % 0..255 index
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; % RGB
        
        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        
        title('Direkcionalitás', 'FontName', 'Times New Roman', 'FontSize', 16)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off 
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    
        n_alf = latoter-sum(strcmp(p_o_alf{j}, 'hamis'));
        figure(8)
        colorIndex = round( (n_alf / 20) * 255 );  
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; 
        
        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        
        title('Alfa', 'FontName', 'Times New Roman', 'FontSize', 16)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off 
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    
        n_angleav = latoter-sum(strcmp(p_o_angleav{j}, 'hamis'));
        figure(9)
        colorIndex = round( (n_angleav / 20) * 255 );  % 0..255 index
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; % RGB
        
        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        
        title('Átlagos elforulási szög', 'FontName', 'Times New Roman', 'FontSize', 16)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off  
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    
    
        n_anglestd = latoter-sum(strcmp(p_o_anglestd{j}, 'hamis'));
        figure(10)
        colorIndex = round( (n_anglestd / 20) * 255 );  
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; 
        
        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        
        title('Elfordulási szög szórás', 'FontName', 'Times New Roman', 'FontSize', 16)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off  
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    
        n_anglezc = latoter-sum(strcmp(p_o_anglezc{j}, 'hamis'));
        figure(11)
        colorIndex = round( (n_anglezc / 20) * 255 );  
        colorIndex = max(0, min(255, colorIndex));
        cmap = [ones(256,1), linspace(1,0,256)', zeros(256,1)]; 
        
        plot(kez(j), N_all{caseNum}(j), '_', ...
            'MarkerSize', 1, ...
            'Color', cmap(colorIndex+1,:), ...
            'LineWidth', 10);
        
        title('Elforulási szög zéro crossing', 'FontName', 'Times New Roman', 'FontSize', 16)
        ylabel('P', 'FontName', 'Times New Roman', 'FontSize', 20)
        xlabel('MF', 'FontName', 'Times New Roman', 'FontSize', 20)
        
        ylim([0 1]);
        grid off 
        set(gca, 'FontName', 'Times New Roman', 'FontSize', 16, 'Color', 'white')
        hold on;
    end
end


    % ===== HELPER FÜGGVÉNYEK =====
function out = ternary(cond, a, b)
    if cond, out = a; else, out = b; end
end

function [isSignificant, p_mean] = local_anova_bootstrap_equal(treat_vec, control_vec, n_per_group, n_boot, alpha)
    treat_vec   = treat_vec(~isnan(treat_vec));
    control_vec = control_vec(~isnan(control_vec));

    % Ha túl kevés adat van, nincs teszt
    if numel(treat_vec) < 2 || numel(control_vec) < 2
        isSignificant = false;
        p_mean = NaN;
        return;
    end

    n = min([n_per_group, numel(treat_vec), numel(control_vec)]);

    pvals = NaN(n_boot,1);
    for b = 1:n_boot
        t_idx = randsample(numel(treat_vec),   n, true);  
        c_idx = randsample(numel(control_vec), n, false); 

        t_s = treat_vec(t_idx);
        c_s = control_vec(c_idx);

        X = [t_s(:), c_s(:)];
        % ANOVA, két csoport, címkék opcionálisak
        p = anova1(X, {'Kezelés','Kontroll'}, 'off');
        pvals(b) = p;
    end

    p_mean = mean(pvals, 'omitnan');
    isSignificant = (~isnan(p_mean)) && (p_mean < alpha);
end

