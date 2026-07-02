%% Cell trackeres és manuálisan kiértékelt file-ok feldolgozása
clc; clear; clf; close all;

% Mappa ahol a celltrackeres excelek/ manuálisan értékel path-ok vannak
ossz_excel = dir('C:\Users\banya\Downloads\Gréti cikk\Kézi+gépi követés eredmények (koordinátás path+excel)\Kovetes_eredmenyek\semi-automatic\*.xls');
ossz_path = dir('C:\Users\banya\Downloads\Gréti cikk\Kézi+gépi követés eredmények (koordinátás path+excel)\Kovetes_eredmenyek\manual\*.path');

T = readtable('kiertekelt_excel.xlsx');
% sim = readtable('szim_v1.xlsx');

%% Színek a plotokhoz
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
c11 = [151 67 154]./255;
c12 = [67 154 79]./255;
c13 = [120 58 70]./255;
c14 = [67 109 154]./255;
c15 = [0 100 0]./255;
c16 = [24 15 130]./255;
c17 = [128 128 0]./255;
c18 = [255 128 145]./255;
c19 = [220 190 255]./255;
c20 = [180 55 85]./255;
c21 = [255 90 110]./255;
c22 = [191 147 96]./255;
c23 = [102 26 87]./255;
c24 = [115 86 86]./255;
c25 = [143 188 191]./255;
c26 = [255 64 170]./255;
c27 = [101 104 120]./255;
c28 = [199 23 133]./255;
c29 = [175 80 177]./255;
c30 = [0 0 0]./255;
c31 = [130 70 0]./255;
c32 = [61 85 61]./255;
cl_colors = {c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c20, c21, c22, c23, c24, c25, c26, c27, c28, c29, c30, c31, c32};
clear c1 c2 c3 c4 c5 c6 c7 c8 c9 c11 c12 c13 c14 c15 c16 c17 c18 c19 c20 c21 c22 c23 c24 c25 c26 c27 c28 c29 c30 c31 c32

% Threshold a zajhoz kapcsolódó elmozdulások kiszedéséhez - zajkiszedéshez: 11, zajjal: 0
epsilon = 11;

% for ciklus használva a több epsilon kipróbálásához (validáláshoz)
% try
% for r = 1 : 301

    %% Kezi kiertekeles
    
    k_msd_ossz  ={};
    k_maxelm_ossz = {};
    k_v_atlag_ossz = {};
    k_v_ossz = {};
    k_megtettut_ossz = {};
    k_elmozd_ossz = {};
    k_megtettut_eddig = {};
    k_ep_dr_ossz = {};
    k_angleav_ossz  ={};
    k_anglestd_ossz = {};
    k_anglezc_ossz = {};
    k_alfa_ossz = {};
    k_x_sejtek = {};
    k_y_sejtek = {};
    k_ut_most_ossz_2std = [];
    
    k_latoter = {};
    k_nev ={};
    k_sv = {};
    k_kez ={};
    k_kont ={};
    k_t = {};
    k_kezsv = {};
    k_gep = {};
    ossz_sejt = 0;
    
    % Beolvassuk a path file-okat
    for j = 1:length(ossz_path)
        z = [ossz_path(j).folder, '\', ossz_path(j).name];
        mostani_file = z;
        jelenlegi_excel = ossz_path(j).name;
        hanyas_excel = strsplit(jelenlegi_excel,'_');
        hanyas_e = strsplit(hanyas_excel{end},'.');
        k_latoter{end+1} = str2double(hanyas_e{1});
        nev1 = strsplit(jelenlegi_excel,'.');
        k_nev{end+1} = nev1{1};
        for h = 1:size(T,1)
            if strcmp(k_nev{j}, T.nev{h})
                k_sv{end+1} = T.sejtvonal{h};
                k_kez{end+1} = T.kezeles{h};
                k_gep{end+1} = T.gep{h};
                k_kont{end+1} = append(T.sejtvonal{h}, ' ', T.kontroll{h}, ' ', T.gep{h});
            end
        end
    
        k_kezsv{end+1} = append(k_sv{end}, ' ', k_kez{end}, ' ', k_gep{end});
    
        % Meghatározzuk az időt két kép között
        if strcmp(k_gep{end}, 'uj')
            t = 20;
        elseif strcmp(k_gep{end}, 'regi')
            t = 15;
        else
            t = 0;
        end
    
        uj = 20;
        ujh = 70;
        regi = 15;
        regih = 92;

        k_t{end+1} = t;
                
        col_titles = {
            'file_name'
            'cell_count'
            'avg_path_length'
            'cnt_length_not_max'
            'osszes_megtett_ut' 
            'osszes_elmozdulas'};
    
        % Itt inicializálunk egy üres táblát
        sejtek_szama_fajlokban = array2table(zeros(0,numel(col_titles)));
        sejtek_szama_fajlokban.Properties.VariableNames = col_titles;
    
    
        % Itt történik a path fájl értelmezése
        [X, Y, CNT, ID] = beolvas(z);

        num_ID = unique(ID);
        
        % Hány elemből állnak az egyes követések:
        GC = groupcounts(ID);
        if  t == 15 && max(GC) > 97
            for f = 1:length(GC)
                GC(f) = 97;
            end
        elseif t == 20 && max(GC) > 73
            for f = 1:length(GC)
                GC(f) = 73;
            end
        end


        % Átlagszámítás
        avg_path_length = mean(GC);

        count_not_max = sum(GC ~= max(GC));

        osszes_megtett_ut = 0;
        osszes_elmozdulas = 0;

        %% Egyesével az útvonalak számolása minden sejtre

        ep_dr_per_file = [];
        v_ossz_per_file = [];
        alfa_per_file = NaN(max(GC), numel(GC));
        angleav_per_file = [];
        anglestd_per_file = [];
        anglezc_per_file = [];
        ut_most_per_file_2std = [];
        maxelm_per_file = NaN(max(GC), numel(GC));
        v_per_file = NaN(max(GC), numel(GC));
        elmozd_per_file = NaN(max(GC), numel(GC));
        msd_per_file2 = NaN(max(GC), numel(GC));
        megtettut_eddig_per_file = NaN(max(GC), numel(GC));
        megtettut_per_file = NaN(max(GC), numel(GC));
        ut_most_ossz_sejt = [];

        h = 0;

        for ez_a_sejt=0:max(ID)
            maszk = ID == ez_a_sejt;

            % 2sd meghatározáshoz - nagy mozgás - feltételezett halott sejt - csak úszik a sejt teoriához
            Y_adott_sejtre = Y(ID==ez_a_sejt);
            X_adott_sejtre = X(ID==ez_a_sejt); 
            ut_most_ossz = [];
            for n=2:size(Y_adott_sejtre)     
               x_sejtre_elozo = X_adott_sejtre(n-1);
               x_sejtre_most =  X_adott_sejtre(n);            
               y_sejtre_elozo = Y_adott_sejtre(n-1);
               y_sejtre_most =  Y_adott_sejtre(n);                       
               ut_most = (sqrt( (x_sejtre_elozo - x_sejtre_most)^2 + ...
                                (y_sejtre_elozo - y_sejtre_most)^2 ));  
               ut_most_ossz = [ut_most_ossz; ut_most];
                            
            end
            ut_most_ossz_sejt = [ut_most_ossz_sejt; ut_most_ossz];
                        
            if ~ismember(ez_a_sejt, ID)
                h = h+1;
                continue
            end
            
            % Biztosra megyünk, hogy a trajektoriák egy hosszúak
            x_sejtre = X(maszk);
            y_sejtre = Y(maszk);
            if t == 15 && size(x_sejtre,1) > 97 || t == 20 && size(x_sejtre,1) > 73
                if t == 15
                    x_sejtre = x_sejtre(1:97);
                    y_sejtre = y_sejtre(1:97);
                elseif t == 20
                    x_sejtre = x_sejtre(1:73);
                    y_sejtre = y_sejtre(1:73);
                end
            end

            k_x_sejtek{end+1} = x_sejtre;
            k_y_sejtek{end+1} = y_sejtre;
            
            ssz = ez_a_sejt - h;
            ssz_2 = ssz + 1;
            
            GCi = GC(ssz_2);
            
            %% Mozgasra jellemzo parameterek kiszamitasa
            
            % Megtett út eddig (ket kep kozott), teljes megtett út - TTD
            megtett_ut_eddig = 0;
            megtett_ut_most_masolat = 0;
            megtett_ut = 0;

            if t == 15 && size(x_sejtre,1) > 92 || t == 20 && size(x_sejtre,1) > 70
                for s =1:numel(x_sejtre)-1                     
                        megtett_ut_most = (sqrt( (x_sejtre(s+1)-x_sejtre(s))^2 + (y_sejtre(s+1)-y_sejtre(s))^2 ))*2.18;
                        megtett_ut_most_masolat(s) = megtett_ut_most;
                        megtett_ut = megtett_ut + megtett_ut_most;
                        megtett_ut_eddig(s) = megtett_ut;
                        megtettut_per_file(s, ssz_2) = megtett_ut_most_masolat(s);
                        megtettut_eddig_per_file(s, ssz_2) = megtett_ut_eddig(s);
                end
            else
            end
            

            % Elmozdulás - D és maximum elmozdulás - MaxD
            maxelm = 0;
            if t == 15 && size(x_sejtre,1) > 92 || t == 20 && size(x_sejtre,1) > 70
                for i = 1:GCi
                    elmozd_per_file(i, ssz_2) = (sqrt( (x_sejtre(i)-x_sejtre(1))^2 + (y_sejtre(i)-y_sejtre(1))^2 ))*2.18; 
                    elmozdulas = elmozd_per_file(i, ssz_2);
                    if ~isnan(elmozdulas) && maxelm < elmozdulas
                        maxelm = elmozdulas;
                    elseif isnan(elmozdulas)
                        maxelm = elmozdulas;
                    end
                    maxelm_per_file(i, ssz_2) = maxelm;
                end
            end

            % Directionality ratio - DR
            if ~isnan(elmozd_per_file(1, ssz_2))
                ep_dr = elmozdulas/megtett_ut;
            else
                ep_dr = elmozd_per_file(1, ssz_2);
            end
            ep_dr_per_file = [ep_dr_per_file, ep_dr];


            % Mean squared displacement-MSD = (1/N-n) * sum egytol N-n-ig (d^2(pi,pi+n) -- n=1:GCi
            msd_per_file = NaN(max(GC), max(GC));
            if t == 15 && size(x_sejtre,1) > 92 || t == 20 && size(x_sejtre,1) > 70
                for n = 1:GCi-1
                    for i = 1:GCi-n                        
                        d2 = (x_sejtre(i+n)-x_sejtre(i))^2 + (y_sejtre(i+n)-y_sejtre(i))^2;
                        d2 = sqrt(d2) * 2.18; %% PX -> um
                        msd_per_file(i,n) = d2;        
                    end                    
                end
                msd_per_file = reshape(permute(msd_per_file, [1,3,2]), size(msd_per_file, 3)*size(msd_per_file, 1), size(msd_per_file, 2))';
    
                darabteli = ~isnan(msd_per_file);
                darabteli = sum(darabteli, 2);
    
                msd_per_file2(:,ssz_2) = mean(msd_per_file, 2, 'omitnan');
            else
            end

            % Turning angle - alfa = tan^-1[yi+1-yi)/(xi+1-xi)] + átlag - ATA
            alfa = [];
            if t == regi && size(x_sejtre, 1) > regih || t == uj && size(x_sejtre, 1) > ujh
                for i = 1:GCi-1                
                    delta_x = x_sejtre(i+1) - x_sejtre(i);
                    delta_y = y_sejtre(i+1) - y_sejtre(i);
                    alfa(i) = atan2(delta_y, delta_x);
                    alfa(i) = rad2deg(alfa(i));
                    if alfa(i) < 0
                        alfa(i) = alfa(i) + 360;
                    end
                    alfa_per_file(i, ssz_2) = alfa(i);
                end
            end
    
            angleav_per_file = mean(alfa_per_file, 1, 'omitnan');
            anglestd_per_file = std(alfa_per_file, 0, 1, 'omitnan');
    
            % Zero-crossing detektálása – körkörös szögkülönbségek alapján - TVZC
            anglezc_per_file = zeros(1, size(alfa_per_file, 2));
    
            for f = 1:size(alfa_per_file, 2)
                angles = alfa_per_file(:,f);
                dtheta = mod(diff(angles) + 180, 360) - 180;
                sign_change = sign(dtheta(1:end-1)) ~= sign(dtheta(2:end));
                valid = (sign(dtheta(1:end-1)) ~= 0) & (sign(dtheta(2:end)) ~= 0);
    
                anglezc_per_file(f) = sum(sign_change & valid);
            end
    
            % Velocity - V = d(pi, pi+1)/delta t  + atlag
            v = [];
            if t == 15 && size(x_sejtre,1) > 92 || t == 20 && size(x_sejtre,1) > 70
                for i = 1:GCi-1                
                    v(i) = ((sqrt( (x_sejtre(i+1)-x_sejtre(i))^2 + (y_sejtre(i+1)-y_sejtre(i))^2 ))/t(end))*2.18;
                    v_per_file(i, ssz_2) = v(i);
                end
            else
            end
            v_atlag = mean(v_per_file(:, ssz_2), 1, 'omitnan');
            v_ossz_per_file = [v_ossz_per_file, v_atlag];


            osszes_megtett_ut = osszes_megtett_ut + (megtett_ut * GC(ssz_2));
            osszes_elmozdulas = osszes_elmozdulas + (elmozdulas * GC(ssz_2));

        end
            
        % Elmozdulas, megtett ut atlag
        osszes_megtett_ut = osszes_megtett_ut / sum(GC);  
        osszes_elmozdulas = osszes_elmozdulas / sum(GC);

        sejtek_szama = length(num_ID);
        ossz_sejt = ossz_sejt + sejtek_szama;

        % Adott parameterek kiirasa tablazatba
        mostani_sor = table({ ...
            mostani_file}, ...
            sejtek_szama, ...
            avg_path_length, ...
            count_not_max, ...
            osszes_megtett_ut, ...
            osszes_elmozdulas, ...
            'VariableNames', col_titles);

        sejtek_szama_fajlokban = [sejtek_szama_fajlokban;mostani_sor];
            

        % Osszes sejtvonal, kezelés parameterei
        k_msd_ossz{end+1} = msd_per_file2;
        k_maxelm_ossz{end+1} = maxelm_per_file;
        k_v_atlag_ossz{end+1} = v_ossz_per_file;
        k_v_ossz{end+1} = v_per_file;
        k_megtettut_ossz{end+1} = megtettut_per_file;
        k_elmozd_ossz{end+1} = elmozd_per_file;
        k_megtettut_eddig{end+1} = megtettut_eddig_per_file;
        k_ep_dr_ossz{end+1} = ep_dr_per_file;
        k_alfa_ossz{end+1} = alfa_per_file;
        k_angleav_ossz{end+1} = angleav_per_file;
        k_anglestd_ossz{end+1} = anglestd_per_file;
        k_anglezc_ossz{end+1} = anglezc_per_file;
        ut_most_per_file_2std = mean(ut_most_ossz_sejt, 1, 'omitnan') + 2 * std(ut_most_ossz_sejt, 0, 1, 'omitnan');
        k_ut_most_ossz_2std = [k_ut_most_ossz_2std ut_most_per_file_2std];
    
      
    end
    
    
    %% Két pont közötti távolság - distribution
    
    k_mu_eddig = NaN(100, ossz_sejt);
    k_mu_eddig_v = [];
    c = 1;
    for k = 1:size(k_megtettut_ossz,2)
        jelenlegi = k_megtettut_ossz{1,k};
        for f = 1:size(jelenlegi,2)
            sorh = size(jelenlegi,1);
            k_mu_eddig(1:sorh,c) = jelenlegi(:,f);
            c = c + 1;
            k_mu_eddig_v = [k_mu_eddig_v; jelenlegi(:,f)];
        end
    end
    
    %% Histogram
    % 
    % h1 = histogram(k_mu_eddig_v,'BinWidth',2);
    % ylim([0 26000]);
    % xlim([0 160]);
    % p1 = histcounts(k_mu_eddig_v,'BinWidth',2,'Normalization','pdf');
    % 
    % figure
    % histogram(k_mu_eddig_v,'BinWidth',2, 'Normalization','pdf');
    % ylim([0 0.012]);
    % xlim([0 160]);
    % hold on
    % binCenters = h1.BinEdges + (h1.BinWidth/2);
    % plot(binCenters(1:end-1), p1, 'r-','LineWidth',1.5)
    % ylim([0 0.012]);
    % xlim([0 160]);
    % 
    % %% kez gepi hist
    % figure
    % binCenters = h.BinEdges + (h.BinWidth/2);
    % plot(binCenters(1:end-1), p, 'r-','LineWidth',1.5)
    % ylim([0 0.12]);
    % xlim([0 100]);
    % hold on
    % binCenters = h1.BinEdges + (h1.BinWidth/2);
    % plot(binCenters(1:end-1), p1, 'g-','LineWidth',1.5)
    % ylim([0 0.12]);
    % xlim([0 100]);
    
    
    
    %% Összerakjuk az azonos kezelés, sejtvonalakat - átlag, szórás számolás
    
    kezsv_masolat = k_kezsv;
    atlagolando1 = {};
    for i = 1:size(k_kezsv, 2)
        valtozo1 = [];
        for j = 1:size(kezsv_masolat, 2)
            km = kezsv_masolat{j};
            if km ~= 0
                if strcmp(k_kezsv{i}, kezsv_masolat{j})
                    valtozo1(end+1) = j;
                    kezsv_masolat{j} = 0;
                end
            end
        end
        if ~isempty(valtozo1)
            atlagolando1{end+1} = valtozo1;
        end
    end
    
    kEl_atlag = {};
    kEl_szoras = {};
    kMu_atlag = {};
    kMu_szoras = {};
    kDR_atlag = {};
    kDR_szoras = {};
    kSeb_atlag = {};
    kSeb_szoras = {};
    kAseb_atlag = {};
    kAseb_szoras = {};
    kMaxe_atlag = {};
    kMaxe_szoras = {};
    kMSD_atlag = {};
    kMSD_szoras = {};
    kAngleav_atlag = {};
    kAngleav_szoras = {};
    kAnglestd_atlag = {};
    kAnglestd_szoras = {};
    kAnglezc_atlag = {};
    kAnglezc_szoras = {};
    kut_most_2std_max = [];
    k_kezsv1 = {};
    k_kez1 = {};
    k_kont1 = {};
    k_sv1 = {};
    k_gep1 = {};
    k_t1 = {};
    k_ltn = {};
    
    
    klat_elmozd_atlag = {};
    klat_megtettut_eddig = {};
    klat_ep_dr_atlag = {};
    klat_v_atlag = {};
    klat_v_atlag_atlag = {};
    klat_maxelm_atlag = {};
    klat_msd_atlag = {};
    klat_angleav_atlag = {};
    klat_anglestd_atlag = {};
    klat_anglezc_atlag = {};
    
    
    for j = 1:size(atlagolando1, 2)
    
        if length(atlagolando1{j}) >= 1
            latt = [];
            kEl = {};
            kMu = {};
            kDR = {};
            kSeb = {};
            kAseb = {};
            kMaxe = {};
            kMSD = {};
            kAngleav = {};
            kAnglestd = {};
            kAnglezc = {};
            kut_most_2std = [];
            parhuzamosok1 = atlagolando1{1, j};
            for i = 1:length(parhuzamosok1)
                kEl{end+1} = k_elmozd_ossz{parhuzamosok1(i)};
                kMu{end+1} = k_megtettut_eddig{parhuzamosok1(i)};
                kDR{end+1} = k_ep_dr_ossz{parhuzamosok1(i)};
                kSeb{end+1} = k_v_ossz{parhuzamosok1(i)};
                kAseb{end+1} = k_v_atlag_ossz{parhuzamosok1(i)};
                kMaxe{end+1} = k_maxelm_ossz{parhuzamosok1(i)};
                kMSD{end+1} = k_msd_ossz{parhuzamosok1(i)};
                kAngleav{end+1} = k_angleav_ossz{parhuzamosok1(i)};
                kAnglestd{end+1} = k_anglestd_ossz{parhuzamosok1(i)};
                kAnglezc{end+1} = k_anglezc_ossz{parhuzamosok1(i)};
                kut_most_2std = [kut_most_2std k_ut_most_ossz_2std(parhuzamosok1(i))];
    
            end
            kut_most_2std_max = [kut_most_2std_max max(kut_most_2std)];
            klat_elmozd_atlag{end+1} = cell2mat(kEl);
            kEl_atlag{end+1} = mean(cell2mat(kEl), 2, 'omitnan');
            kEl_szoras{end+1} = std(cell2mat(kEl), 0, 2, 'omitnan')/sqrt(size(cell2mat(kEl),2));
            klat_megtettut_eddig{end+1} = cell2mat(kMu);
            kMu_atlag{end+1} = mean(cell2mat(kMu), 2, 'omitnan');
            kMu_szoras{end+1} = std(cell2mat(kMu), 0, 2, 'omitnan')/sqrt(size(cell2mat(kMu),2));
            klat_ep_dr_atlag{end+1} = cell2mat(kDR);
            kDR_atlag{end+1} = mean(cell2mat(kDR), 2, 'omitnan');
            kDR_szoras{end+1} = (std(cell2mat(kDR), 0, 2, 'omitnan')/mean(cell2mat(kDR), 2, 'omitnan'))*100;
            klat_v_atlag{end+1} = cell2mat(kSeb);
            kSeb_atlag{end+1} = mean(cell2mat(kSeb), 2, 'omitnan');
            kSeb_szoras{end+1} = std(cell2mat(kSeb), 0, 2, 'omitnan')/sqrt(size(cell2mat(kSeb),2));
            klat_v_atlag_atlag{end+1} = cell2mat(kAseb);
            kAseb_atlag{end+1} = mean(cell2mat(kAseb), 2, 'omitnan');
            kAseb_szoras{end+1} = (std(cell2mat(kAseb), 0, 2, 'omitnan')/mean(cell2mat(kAseb), 2, 'omitnan'))*100;
            klat_maxelm_atlag{end+1} = cell2mat(kMaxe);
            kMaxe_atlag{end+1} = mean(cell2mat(kMaxe), 2, 'omitnan');
            kMaxe_szoras{end+1} = std(cell2mat(kMaxe), 0, 2, 'omitnan')/sqrt(size(cell2mat(kMaxe),2));
            klat_msd_atlag{end+1} = cell2mat(kMSD);
            kMSD_atlag{end+1} = mean(cell2mat(kMSD), 2, 'omitnan');
            kMSD_szoras{end+1} = std(cell2mat(kMSD), 0, 2, 'omitnan')/sqrt(size(cell2mat(kMSD),2));
            klat_angleav_atlag{end+1} = cell2mat(kAngleav);
            kAngleav_atlag{end+1} = mean(cell2mat(kAngleav), 2, 'omitnan');
            kAngleav_szoras{end+1} = (std(cell2mat(kAngleav), 0, 2, 'omitnan')/mean(cell2mat(kAngleav), 2, 'omitnan'))*100;
            klat_anglestd_atlag{end+1} = cell2mat(kAnglestd);
            kAnglestd_atlag{end+1} = mean(cell2mat(kAnglestd), 2, 'omitnan');
            kAnglestd_szoras{end+1} = (std(cell2mat(kAnglestd), 0, 2, 'omitnan')/mean(cell2mat(kAnglestd), 2, 'omitnan'))*100;
            klat_anglezc_atlag{end+1} = cell2mat(kAnglezc);
            kAnglezc_atlag{end+1} = mean(cell2mat(kAnglezc), 2, 'omitnan');
            kAnglezc_szoras{end+1} = (std(cell2mat(kAnglezc), 0, 2, 'omitnan')/mean(cell2mat(kAnglezc), 2, 'omitnan'))*100;
    
            latt = sum(latt);
            elso = parhuzamosok1(1);
            k_kezsv1{end+1} = k_kezsv{elso};
            k_kez1{end+1} = k_kez{elso};
            k_kont1{end+1} = k_kont{elso};
            k_sv1{end+1} = k_sv{elso};
            k_gep1{end+1} = k_gep{elso};
            k_t1{end+1} = k_t{elso};
            k_ltn{end+1} = size(klat_elmozd_atlag{j},2);
    
        end
    end
    
    %% Kontroll gorbe allatti teruletenek kiszamolasa (AUC)
    
    kMaxT_elmozd = {};
    kMinT_elmozd = {};
    kMaxT_msd = {};
    kMinT_msd = {};
    kMaxT_v = {};
    kMinT_v = {};
    kMaxT_v_a = {};
    kMinT_v_a = {};
    kMaxT_mu = {};
    kMinT_mu = {};
    kMaxT_maxe = {};
    kMinT_maxe = {};
    kMaxT_dr = {};
    kMinT_dr = {};
    kMaxT_angleav = {};
    kMinT_angleav = {};
    kMaxT_anglestd = {};
    kMinT_anglestd = {};
    kMaxT_anglezc = {};
    kMinT_anglezc = {};
    
    k_ksv = {};
    k_kgep = {};
    k_kkezsv = {};
    k_knum = [];
    
    k_svk = {};
    k_gepk = {};
    k_kezsvk = {};
    k_numk = [];
    
    %% Kontroll latoterek osszehasonlitasa (átlaghoz)
    
    for j = 1:size(atlagolando1, 2)
        jelenlegi_sejt = atlagolando1{1, j};
        kMaxT_elmozd1 = [];
        kMinT_elmozd1 = [];
        kMaxT_msd1 = [];
        kMinT_msd1 = [];
        kMaxT_v1 = [];
        kMinT_v1 = [];
        kMaxT_v_a1 = [];
        kMinT_v_a1 = [];
        kMaxT_mu1 = [];
        kMinT_mu1 = [];
        kMaxT_maxe1 = [];
        kMinT_maxe1 = [];
        kMaxT_dr1 = [];
        kMinT_dr1 = [];
        kMaxT_angleav1 = [];
        kMinT_angleav1 = [];
        kMaxT_anglestd1 = [];
        kMinT_anglestd1 = [];
        kMaxT_anglezc1 = [];
        kMinT_anglezc1 = [];
        for h = 1:length(jelenlegi_sejt)
            jelen = k_kezsv{jelenlegi_sejt(h)};
            if strcmp(k_kez1{j}, 'kont') || strcmp(k_kez1{j}, 'kont 5%') || strcmp(k_kez1{j}, 'GFP') || strcmp(k_kez1{j}, 'mock') || strcmp(k_kez1{j}, 'scram') || strcmp(k_kez1{j}, 'scraml')
                if h == 1
                    k_ksv{end+1} = k_sv1{j};
                    k_kgep{end+1} = k_gep1{j};
                    k_kkezsv{end+1} = k_kezsv1{j};
                    k_knum = [k_knum j];
                end
                hanysejt = k_maxelm_ossz{1,jelenlegi_sejt(h)};
                for k = 1:size(hanysejt,2)
    
                    eo = k_elmozd_ossz{1,jelenlegi_sejt(h)};
                    max_e = max(kEl_atlag{:,j},eo(:,k));
                    max_e = max_e(~isnan(max_e));
                    min_e = min(kEl_atlag{:,j},eo(:,k));
                    min_e = min_e(~isnan(min_e));
                    kMaxT_elmozd1 = [kMaxT_elmozd1 trapz(max_e)];
                    kMinT_elmozd1 = [kMinT_elmozd1 trapz(min_e)];
        
                    msdo = k_msd_ossz{1,jelenlegi_sejt(h)};
                    max_msd = max(kMSD_atlag{:,j},msdo(:,k));
                    max_msd = max_msd(~isnan(max_msd));
                    min_msd = min(kMSD_atlag{:,j},msdo(:,k));
                    min_msd = min_msd(~isnan(min_msd));
                    kMaxT_msd1 = [kMaxT_msd1 trapz(max_msd)];
                    kMinT_msd1 = [kMinT_msd1 trapz(min_msd)];
        
                    vo = k_v_ossz{1,jelenlegi_sejt(h)};
                    max_v = max(kSeb_atlag{:,j},vo(:,k));
                    max_v = max_v(~isnan(max_v));
                    min_v = min(kSeb_atlag{:,j},vo(:,k));
                    min_v = min_v(~isnan(min_v));
                    kMaxT_v1 = [kMaxT_v1 trapz(max_v)];
                    kMinT_v1 = [kMinT_v1 trapz(min_v)];
        
                    vao = k_v_atlag_ossz{jelenlegi_sejt(h)};
                    kMaxT_v_a1 = [kMaxT_v_a1 max(mean(klat_v_atlag_atlag{1,j}, 2, 'omitnan'),vao(:,k))];
                    kMinT_v_a1 = [kMinT_v_a1 min(mean(klat_v_atlag_atlag{1,j}, 2, 'omitnan'),vao(:,k))];
    
                    muo = k_megtettut_eddig{1,jelenlegi_sejt(h)};
                    max_mu = max(kMu_atlag{:,j},muo(:,k));
                    max_mu = max_mu(~isnan(max_mu));
                    min_mu = min(kMu_atlag{:,j},muo(:,k));
                    min_mu = min_mu(~isnan(min_mu));
                    kMaxT_mu1 = [kMaxT_mu1 trapz(max_mu)];
                    kMinT_mu1 = [kMinT_mu1 trapz(min_mu)];
        
                    maxeo = k_maxelm_ossz{1,jelenlegi_sejt(h)};
                    max_maxe = max(kMaxe_atlag{:,j},maxeo(:,k));
                    max_maxe = max_maxe(~isnan(max_maxe));
                    min_maxe = min(kMaxe_atlag{:,j},maxeo(:,k));
                    min_maxe = min_maxe(~isnan(min_maxe));
                    kMaxT_maxe1 = [kMaxT_maxe1 trapz(max_maxe)];
                    kMinT_maxe1 = [kMinT_maxe1 trapz(min_maxe)];
                        
                    dro = k_ep_dr_ossz{jelenlegi_sejt(h)};
                    kMaxT_dr1 = [kMaxT_dr1 max(mean(klat_ep_dr_atlag{1,j}, 2, 'omitnan'),dro(:,k))];
                    kMinT_dr1 = [kMinT_dr1 min(mean(klat_ep_dr_atlag{1,j}, 2, 'omitnan'),dro(:,k))];

                    angleavo = k_angleav_ossz{jelenlegi_sejt(h)};
                    kMaxT_angleav1 = [kMaxT_angleav1 max(mean(klat_angleav_atlag{1,j}, 2, 'omitnan'),angleavo(:,k))];
                    kMinT_angleav1 = [kMinT_angleav1 min(mean(klat_angleav_atlag{1,j}, 2, 'omitnan'),angleavo(:,k))];

                    anglestdo = k_anglestd_ossz{jelenlegi_sejt(h)};
                    kMaxT_anglestd1 = [kMaxT_anglestd1 max(mean(klat_anglestd_atlag{1,j}, 2, 'omitnan'),anglestdo(:,k))];
                    kMinT_anglestd1 = [kMinT_anglestd1 min(mean(klat_anglestd_atlag{1,j}, 2, 'omitnan'),anglestdo(:,k))];

                    anglezco = k_anglezc_ossz{jelenlegi_sejt(h)};
                    kMaxT_anglezc1 = [kMaxT_anglezc1 max(mean(klat_anglezc_atlag{1,j}, 2, 'omitnan'),anglezco(:,k))];
                    kMinT_anglezc1 = [kMinT_anglezc1 min(mean(klat_anglezc_atlag{1,j}, 2, 'omitnan'),anglezco(:,k))];
                end 
            else
                if h == 1
                    k_svk{end+1} = k_sv1{j};
                    k_gepk{end+1} = k_gep1{j};
                    k_kezsvk{end+1} = k_kezsv1{j};
                    k_numk = [k_numk j];
                end
            end
        end
        if ~isempty(kMaxT_elmozd1)
            kMaxT_elmozd{end+1} = kMaxT_elmozd1;
            kMinT_elmozd{end+1} = kMinT_elmozd1;
            kMaxT_msd{end+1} = kMaxT_msd1;
            kMinT_msd{end+1} = kMinT_msd1;
            kMaxT_v{end+1} = kMaxT_v1;
            kMinT_v{end+1} = kMinT_v1;
            kMaxT_v_a{end+1} = kMaxT_v_a1;
            kMinT_v_a{end+1} = kMinT_v_a1;
            kMaxT_mu{end+1} = kMaxT_mu1;
            kMinT_mu{end+1} = kMinT_mu1;
            kMaxT_maxe{end+1} = kMaxT_maxe1;
            kMinT_maxe{end+1} = kMinT_maxe1;
            kMaxT_dr{end+1} = kMaxT_dr1;
            kMinT_dr{end+1} = kMinT_dr1;
            kMaxT_angleav{end+1} = kMaxT_angleav1;
            kMinT_angleav{end+1} = kMinT_angleav1;
            kMaxT_anglestd{end+1} = kMaxT_anglestd1;
            kMinT_anglestd{end+1} = kMinT_anglestd1;
            kMaxT_anglezc{end+1} = kMaxT_anglezc1;
            kMinT_anglezc{end+1} = kMinT_anglezc1;
        end
    end
    clear kMaxT_elmozd1 kMinT_elmozd1 kMaxT_msd1 kMinT_msd1 kMaxT_v1 kMinT_v1 kMaxT_v_a1 kMinT_v_a1 kMaxT_mu1 kMinT_mu1 kMaxT_maxe1 kMinT_maxe1 kMaxT_dr1 kMinT_dr1
    
    k_kT_elmozd = {};
    k_kT_msd = {};
    k_kT_v = {};
    k_kT_v_a = {};
    k_kT_mu = {};
    k_kT_maxe = {};
    k_kT_dr = {};
    k_kT_angleav = {};
    k_kT_anglestd = {};
    k_kT_anglezc = {};
    
    kT_elmozd_atlag = [];
    kT_msd_atlag = [];
    kT_v_atlag = [];
    kT_mu_atlag = [];
    kT_maxe_atlag = [];
    
    kT_elmozd_lat_szor = [];
    kT_msd_lat_szor = [];
    kT_v_lat_szor = [];
    kT_mu_lat_szor = [];
    kT_maxe_lat_szor = [];
    
    for j = 1:size(k_kezsv1,2)
        kT_elmozd_lat = [];
        kT_msd_lat = [];
        kT_v_lat = [];
        kT_mu_lat = [];
        kT_maxe_lat = [];
    
        msdatlagideig = kMSD_atlag{:,j};
        MSD_atlag_ideig = msdatlagideig(1:end-1);
        sebatlagideig = kSeb_atlag{:,j};
        Seb_atlag__ideig = sebatlagideig(1:end-1);
        muatlagideig = kMu_atlag{:,j};
        Mu_atlag_ideig = muatlagideig(1:end-1);
        
        kT_elmozd_atlag = [kT_elmozd_atlag trapz(kEl_atlag{j})];
        kT_msd_atlag = [kT_msd_atlag trapz(MSD_atlag_ideig)];
        kT_v_atlag = [kT_v_atlag trapz(Seb_atlag__ideig)];
        kT_mu_atlag = [kT_mu_atlag trapz(Mu_atlag_ideig)];
        kT_maxe_atlag = [kT_maxe_atlag trapz(kMaxe_atlag{j})];
        for i = 1:size(klat_elmozd_atlag{j},2)
            kT_elmozd_lat = [kT_elmozd_lat trapz(klat_elmozd_atlag{1,j}(:,i))];
            kT_msd_lat = [kT_msd_lat trapz(klat_msd_atlag{1,j}(1:end-1,i))];
            kT_v_lat = [kT_v_lat trapz(klat_v_atlag{1,j}(1:end-1,i))];
            kT_mu_lat = [kT_mu_lat trapz(klat_megtettut_eddig{1,j}(1:end-1,i))];
            kT_maxe_lat = [kT_maxe_lat trapz(klat_maxelm_atlag{1,j}(:,i))];
        end
        kT_elmozd_lat_szor = [kT_elmozd_lat_szor (std(kT_elmozd_lat, 'omitnan')/mean(kT_elmozd_lat, 'omitnan'))*100];
        kT_msd_lat_szor = [kT_msd_lat_szor (std(kT_msd_lat, 'omitnan')/mean(kT_msd_lat, 'omitnan'))*100];
        kT_v_lat_szor = [kT_v_lat_szor (std(kT_v_lat, 'omitnan')/mean(kT_v_lat, 'omitnan'))*100];
        kT_mu_lat_szor = [kT_mu_lat_szor (std(kT_mu_lat, 'omitnan')/mean(kT_mu_lat, 'omitnan'))*100];
        kT_maxe_lat_szor = [kT_maxe_lat_szor (std(kT_maxe_lat, 'omitnan')/mean(kT_maxe_lat, 'omitnan'))*100];
    end
    
    for i = 1:size(k_kkezsv,2)
        k_kT_elmozd1 = [];
        k_kT_msd1 = [];
        k_kT_v1 = [];
        k_kT_v_a1 = [];
        k_kT_mu1 = [];
        k_kT_maxe1 = [];
        k_kT_dr1 = [];
        k_kT_angleav1 = [];
        k_kT_anglestd1 = [];
        k_kT_anglezc1 = [];
        for j = 1:size(k_kezsv1,2)
            if strcmp(k_kkezsv{i}, k_kezsv1{j})
                for h = 1:size(kMaxT_elmozd{i}, 2)
                    jelenlegi_sejt = {1, j};
                    T_elm_ossz = [(kT_elmozd_atlag(j)-kMinT_elmozd{1,i}(1,h))*-1 kMaxT_elmozd{1,i}(1,h)-kT_elmozd_atlag(j)];
                    k_kT_elmozd1 = [k_kT_elmozd1 sum(T_elm_ossz)];
                    T_msd_ossz = [(kT_msd_atlag(j)-kMinT_msd{1,i}(1,h))*-1 kMaxT_msd{1,i}(1,h)-kT_msd_atlag(j)];
                    k_kT_msd1 = [k_kT_msd1 sum(T_msd_ossz)];
                    T_v_ossz = [(kT_v_atlag(j)-kMinT_v{1,i}(1,h))*-1 kMaxT_v{1,i}(1,h)-kT_v_atlag(j)];
                    k_kT_v1 = [k_kT_v1 sum(T_v_ossz)];
                    T_mu_ossz = [(kT_mu_atlag(j)-kMinT_mu{1,i}(1,h))*-1 kMaxT_mu{1,i}(1,h)-kT_mu_atlag(j)];
                    k_kT_mu1 = [k_kT_mu1 sum(T_mu_ossz)];
                    T_maxe_ossz = [(kT_maxe_atlag(j)-kMinT_maxe{1,i}(1,h))*-1 kMaxT_maxe{1,i}(1,h)-kT_maxe_atlag(j)];
                    k_kT_maxe1 = [k_kT_maxe1 sum(T_maxe_ossz)];
                    T_v_a_ossz = [(mean(klat_v_atlag_atlag{1,j}, 2, 'omitnan')-kMinT_v_a{1,i}(1,h))*-1 kMaxT_v_a{1,i}(1,h)-mean(klat_v_atlag_atlag{1,j}, 2, 'omitnan')];
                    k_kT_v_a1 = [k_kT_v_a1 sum(T_v_a_ossz)];
                    T_dr_ossz = [(mean(klat_ep_dr_atlag{1,j}, 2, 'omitnan')-kMinT_dr{1,i}(1,h))*-1 kMaxT_dr{1,i}(1,h)-mean(klat_ep_dr_atlag{1,j}, 2, 'omitnan')];
                    k_kT_dr1 = [k_kT_dr1 sum(T_dr_ossz)];
                    T_angleav_ossz = [(mean(klat_angleav_atlag{1,j}, 2, 'omitnan')-kMinT_angleav{1,i}(1,h))*-1 kMaxT_angleav{1,i}(1,h)-mean(klat_angleav_atlag{1,j}, 2, 'omitnan')];
                    k_kT_angleav1 = [k_kT_angleav1 sum(T_angleav_ossz)];
                    T_anglestd_ossz = [(mean(klat_anglestd_atlag{1,j}, 2, 'omitnan')-kMinT_anglestd{1,i}(1,h))*-1 kMaxT_anglestd{1,i}(1,h)-mean(klat_anglestd_atlag{1,j}, 2, 'omitnan')];
                    k_kT_anglestd1 = [k_kT_anglestd1 sum(T_anglestd_ossz)];
                    T_anglezc_ossz = [(mean(klat_anglezc_atlag{1,j}, 2, 'omitnan')-kMinT_anglezc{1,i}(1,h))*-1 kMaxT_anglezc{1,i}(1,h)-mean(klat_anglezc_atlag{1,j}, 2, 'omitnan')];
                    k_kT_anglezc1 = [k_kT_anglezc1 sum(T_anglezc_ossz)];
                end
            end
        end
        if ~isempty(k_kT_elmozd1)
            k_kT_elmozd{end+1} = k_kT_elmozd1;
            k_kT_msd{end+1} = k_kT_msd1;
            k_kT_v{end+1} = k_kT_v1;
            k_kT_v_a{end+1} = k_kT_v_a1;
            k_kT_mu{end+1} = k_kT_mu1;
            k_kT_maxe{end+1} = k_kT_maxe1;
            k_kT_dr{end+1} = k_kT_dr1;
            k_kT_angleav{end+1} = k_kT_angleav1;
            k_kT_anglestd{end+1} = k_kT_anglestd1;
            k_kT_anglezc{end+1} = k_kT_anglezc1;
        end
    end
    
    thr_e = {};
    thr_msd = {};
    thr_v = {};
    thr_mu = {};
    thr_maxe = {};
    thr_v_a = {};
    thr_dr = {};
    thr_angleav = {};
    thr_anglestd = {};
    thr_anglezc = {};


    % Szimuláció validálásához használt - mennyire illeszkedik a szimulált adat a valóshoz
    sim_par = readtable('sim_par.xlsx');
    sim_par = table2array(sim_par);
    close all;
    
    all_data = []; 
    
    for i = 1:length(k_knum)
        cellIndex = k_knum(i);
        data = mean(klat_ep_dr_atlag{cellIndex}, 2, 'omitnan');
        all_data = [all_data, data]; 
    end
    
    % Piros oszlop hozzáadása (sim_par 6. oszlop)
    all_data = [all_data, sim_par(1,7)];
    
    mean_vals = mean(all_data, 1, 'omitnan');
    
    % Rendezés és új indexek követése
    [sorted_vals, sort_idx] = sort(mean_vals, 'descend');
    
    original_red_idx = size(all_data, 2);  
    new_red_idx = find(sort_idx == original_red_idx);
    
    % Szürke árnyalatok generálása
    grayShades = linspace(0.1, 0.9, length(mean_vals))'; 
    colors = repmat(grayShades, 1, 3);  
    
    % A piros indexeket állítsuk pirosra
    colors(new_red_idx, :) = repmat([1 0 0], length(new_red_idx), 1);
 
    % Ábra
    figure; 
    b = bar(sorted_vals, 'FaceColor', 'flat');
    b.CData = colors;
    b.BarWidth = 1;
    b.EdgeColor = 'k';  
    b.LineWidth = 0.5;  

    b.FaceAlpha = 1;
    
    xticklabels([]);  
    xticks([]); 
    ax = gca;  
    ax.YAxis.FontName = 'Times New Roman';   
    ax.YAxis.FontSize = 30;
    ylabel('DR', 'FontName', 'Times New Roman', 'FontWeight', 'bold', 'FontSize', 35);
    box off;  
    ax.XColor = 'k';  
    ax.YColor = 'k';  
    ax.XAxisLocation = 'bottom';
    ax.YAxisLocation = 'left';
    ax.Box = 'off';

    
    %% 95% confidence interval - igazából később nem használt
    for i = 1:size(k_kT_elmozd,2)
        SEM_e = std(k_kT_elmozd{1,i})/sqrt(length(k_kT_elmozd{1,i}));
        ts_e = tinv([0.025  0.975],length(k_kT_elmozd{1,i})-1);
        thr1_e = (mean(k_kT_elmozd{1,i}) + ts_e*SEM_e);
        thr_e{end+1} = thr1_e;
    
        SEM_msd = std(k_kT_msd{1,i})/sqrt(length(k_kT_msd{1,i}));
        ts_msd = tinv([0.025  0.975],length(k_kT_msd{1,i})-1);
        thr1_msd = mean(k_kT_msd{1,i}) + ts_msd*SEM_msd;
        thr_msd{end+1} = thr1_msd;
    
        SEM_v = std(k_kT_v{1,i})/sqrt(length(k_kT_v{1,i}));
        ts_v = tinv([0.025  0.975],length(k_kT_v{1,i})-1);
        thr1_v = mean(k_kT_v{1,i}) + ts_v*SEM_v;
        thr_v{end+1} = thr1_v;
    
        SEM_mu = std(k_kT_mu{1,i})/sqrt(length(k_kT_mu{1,i}));
        ts_mu = tinv([0.025  0.975],length(k_kT_mu{1,i})-1);
        thr1_mu = mean(k_kT_mu{1,i}) + ts_mu*SEM_mu;
        thr_mu{end+1} = thr1_mu;
    
        SEM_maxe = std(k_kT_maxe{1,i})/sqrt(length(k_kT_maxe{1,i}));
        ts_maxe = tinv([0.025  0.975],length(k_kT_maxe{1,i})-1);
        thr1_maxe = mean(k_kT_maxe{1,i}) + ts_maxe*SEM_maxe;
        thr_maxe{end+1} = thr1_maxe;
    
        SEM_v_a = std(k_kT_v_a{1,i})/sqrt(length(k_kT_v_a{1,i}));
        ts_v_a = tinv([0.025  0.975],length(k_kT_v_a{1,i})-1);
        thr1_v_a = mean(k_kT_v_a{1,i}) + ts_v_a*SEM_v_a;
        thr_v_a{end+1} = thr1_v_a;
    
        SEM_dr = std(k_kT_dr{1,i})/sqrt(length(k_kT_dr{1,i}));
        ts_dr = tinv([0.025  0.975],length(k_kT_dr{1,i})-1);
        thr1_dr = mean(k_kT_dr{1,i}) + ts_dr*SEM_dr;
        thr_dr{end+1} = thr1_dr;

        SEM_angleav = std(k_kT_angleav{1,i})/sqrt(length(k_kT_angleav{1,i}));
        ts_angleav = tinv([0.025  0.975],length(k_kT_angleav{1,i})-1);
        thr1_angleav = mean(k_kT_angleav{1,i}) + ts_angleav*SEM_angleav;
        thr_angleav{end+1} = thr1_angleav;
    
        SEM_anglestd = std(k_kT_anglestd{1,i})/sqrt(length(k_kT_anglestd{1,i}));
        ts_anglestd = tinv([0.025  0.975],length(k_kT_anglestd{1,i})-1);
        thr1_anglestd = mean(k_kT_anglestd{1,i}) + ts_anglestd*SEM_anglestd;
        thr_anglestd{end+1} = thr1_anglestd;
    
        SEM_anglezc = std(k_kT_anglezc{1,i})/sqrt(length(k_kT_anglezc{1,i}));
        ts_anglezc = tinv([0.025  0.975],length(k_kT_anglezc{1,i})-1);
        thr1_anglezc = mean(k_kT_anglezc{1,i}) + ts_anglezc*SEM_anglezc;
        thr_anglezc{end+1} = thr1_anglezc;
    end
    
    k_kezsv2 = k_kezsv1';
    
    %% Kezelesek puffer atlag osszehasonlitasa (kezeles AUC es puffer AUC)
    kT_elmozd = {};
    kT_msd = {};
    kT_v = {};
    kT_v_a = {};
    kT_mu = {};
    kT_maxe = {};
    kT_dr = {};
    kT_angleav = {};
    kT_anglestd = {};
    kT_anglezc = {};
    Tnev = {};
    k_KontT = [];
    k_KontT1 = [];
    
    for j = 1:size(klat_msd_atlag, 2)
        jelenlegi_sejt = klat_msd_atlag{1, j};
        kT_elmozd1 = [];
        kT_msd1 = [];
        kT_v1 = [];
        kT_v_a1 = [];
        kT_mu1 = [];
        kT_maxe1 = [];
        kT_dr1 = [];
        kT_angleav1 = [];
        kT_anglestd1 = [];
        kT_anglezc1 = [];
    
        KontT1 = [];
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
        MaxT_angleav = [];
        MinT_angleav = [];
        MaxT_anglestd = [];
        MinT_anglestd = [];
        MaxT_anglezc = [];
        MinT_anglezc = [];
    
        for g = 1:length(k_kezsv1)
            if strcmp(k_kont1{j}, k_kezsv1{g})
                KontT1 = g;
            end
        end
        k_KontT2 = find(k_knum == KontT1);
        k_KontT1 = [k_KontT1 k_KontT2];
        k_KontT = [k_KontT KontT1];
    
        for h = 1:size(jelenlegi_sejt,2)
    
            max_e = max(kEl_atlag{KontT1},klat_elmozd_atlag{1,j}(:,h));
            max_e = max_e(~isnan(max_e));
            min_e = min(kEl_atlag{KontT1},klat_elmozd_atlag{1,j}(:,h));
            min_e = min_e(~isnan(min_e));
            MaxT_elmozd = [MaxT_elmozd trapz(max_e)];
            MinT_elmozd = [MinT_elmozd trapz(min_e)];
        
            T_elm_ossz = [(kT_elmozd_atlag(KontT1)-MinT_elmozd(h))*-1 MaxT_elmozd(h)-kT_elmozd_atlag(KontT1)];
            kT_elmozd1 = [kT_elmozd1 sum(T_elm_ossz)];
        
            max_msd = max(kMSD_atlag{KontT1},klat_msd_atlag{1,j}(:,h));
            max_msd = max_msd(~isnan(max_msd));
            min_msd = min(kMSD_atlag{KontT1},klat_msd_atlag{1,j}(:,h));
            min_msd = min_msd(~isnan(min_msd));
            MaxT_msd = [MaxT_msd trapz(max_msd)];
            MinT_msd = [MinT_msd trapz(min_msd)];
        
            T_msd_ossz = [(kT_msd_atlag(KontT1)-MinT_msd(h))*-1 MaxT_msd(h)-kT_msd_atlag(KontT1)];
            kT_msd1 = [kT_msd1 sum(T_msd_ossz)];
        
            max_v = max(kSeb_atlag{KontT1},klat_v_atlag{1,j}(:,h));
            max_v = max_v(~isnan(max_v));
            min_v = min(kSeb_atlag{KontT1},klat_v_atlag{1,j}(:,h));
            min_v = min_v(~isnan(min_v));
            MaxT_v = [MaxT_v trapz(max_v)];
            MinT_v = [MinT_v trapz(min_v)];
        
            T_v_ossz = [(kT_v_atlag(KontT1)-MinT_v(h))*-1 MaxT_v(h)-kT_v_atlag(KontT1)];
            kT_v1 = [kT_v1 sum(T_v_ossz)];
        
            max_mu = max(kMu_atlag{KontT1},klat_megtettut_eddig{1,j}(:,h));
            max_mu = max_mu(~isnan(max_mu));
            min_mu = min(kMu_atlag{KontT1},klat_megtettut_eddig{1,j}(:,h));
            min_mu = min_mu(~isnan(min_mu));
            MaxT_mu = [MaxT_mu trapz(max_mu)];
            MinT_mu = [MinT_mu trapz(min_mu)];
        
            T_mu_ossz = [(kT_mu_atlag(KontT1)-MinT_mu(h))*-1 MaxT_mu(h)-kT_mu_atlag(KontT1)];
            kT_mu1 = [kT_mu1 sum(T_mu_ossz)];
        
            max_maxe = max(kMaxe_atlag{KontT1},klat_maxelm_atlag{1,j}(:,h));
            max_maxe = max_maxe(~isnan(max_maxe));
            min_maxe = min(kMaxe_atlag{KontT1},klat_maxelm_atlag{1,j}(:,h));
            min_maxe = min_maxe(~isnan(min_maxe));
            MaxT_maxe = [MaxT_maxe trapz(max_maxe)];
            MinT_maxe = [MinT_maxe trapz(min_maxe)];
        
            T_maxe_ossz = [(kT_maxe_atlag(KontT1)-MinT_maxe(h))*-1 MaxT_maxe(h)-kT_maxe_atlag(KontT1)];
            kT_maxe1 = [kT_maxe1 sum(T_maxe_ossz)];
    
            max_v_a = max(kAseb_atlag{KontT1},klat_v_atlag_atlag{1,j}(:,h));
            min_v_a = min(kAseb_atlag{KontT1},klat_v_atlag_atlag{1,j}(:,h));
            MaxT_v_a = [MaxT_v_a max_v_a];
            MinT_v_a = [MinT_v_a min_v_a];
        
            T_v_a_ossz = [(kAseb_atlag{KontT1}-MinT_v_a(h))*-1 MaxT_v_a(h)-kAseb_atlag{KontT1}];
            kT_v_a1 = [kT_v_a1 sum(T_v_a_ossz)];
    
            max_dr = max(kDR_atlag{KontT1},klat_ep_dr_atlag{1,j}(:,h));
            min_dr = min(kDR_atlag{KontT1},klat_ep_dr_atlag{1,j}(:,h));
            MaxT_dr = [MaxT_dr max_dr];
            MinT_dr = [MinT_dr min_dr];
        
            T_dr_ossz = [(kDR_atlag{KontT1}-MinT_dr(h))*-1 MaxT_dr(h)-kDR_atlag{KontT1}];
            kT_dr1 = [kT_dr1 sum(T_dr_ossz)];

            max_angleav = max(kAngleav_atlag{KontT1},klat_angleav_atlag{1,j}(:,h));
            min_angleav = min(kAngleav_atlag{KontT1},klat_angleav_atlag{1,j}(:,h));
            MaxT_angleav = [MaxT_angleav max_angleav];
            MinT_angleav = [MinT_angleav min_angleav];
        
            T_angleav_ossz = [(kAngleav_atlag{KontT1}-MinT_angleav(h))*-1 MaxT_angleav(h)-kAngleav_atlag{KontT1}];
            kT_angleav1 = [kT_angleav1 sum(T_angleav_ossz)];

            max_anglestd = max(kAnglestd_atlag{KontT1},klat_anglestd_atlag{1,j}(:,h));
            min_anglestd = min(kAnglestd_atlag{KontT1},klat_anglestd_atlag{1,j}(:,h));
            MaxT_anglestd = [MaxT_anglestd max_anglestd];
            MinT_anglestd = [MinT_anglestd min_anglestd];
        
            T_anglestd_ossz = [(kAnglestd_atlag{KontT1}-MinT_anglestd(h))*-1 MaxT_anglestd(h)-kAnglestd_atlag{KontT1}];
            kT_anglestd1 = [kT_anglestd1 sum(T_anglestd_ossz)];

            max_anglezc = max(kAnglezc_atlag{KontT1},klat_anglezc_atlag{1,j}(:,h));
            min_anglezc = min(kAnglezc_atlag{KontT1},klat_anglezc_atlag{1,j}(:,h));
            MaxT_anglezc = [MaxT_anglezc max_anglezc];
            MinT_anglezc = [MinT_anglezc min_anglezc];
        
            T_anglezc_ossz = [(kAnglezc_atlag{KontT1}-MinT_anglezc(h))*-1 MaxT_anglezc(h)-kAnglezc_atlag{KontT1}];
            kT_anglezc1 = [kT_anglezc1 sum(T_anglezc_ossz)];
    
            Tnev{end+1} = append(k_kezsv1{j});
        end
        kT_elmozd{end+1} = kT_elmozd1;
        kT_msd{end+1} = kT_msd1;
        kT_v{end+1} = kT_v1;
        kT_v_a{end+1} = kT_v_a1;
        kT_mu{end+1} = kT_mu1;
        kT_maxe{end+1} = kT_maxe1;
        kT_dr{end+1} = kT_dr1;
        kT_angleav{end+1} = kT_angleav1;
        kT_anglestd{end+1} = kT_anglestd1;
        kT_anglezc{end+1} = kT_anglezc1;
    end
    
    kT_a_elm_ossz = [];
    kT_a_msd_ossz = [];
    kT_a_maxe_ossz = [];
    kT_a_v_ossz = [];
    kT_a_av_ossz = [];
    kT_a_dr_ossz = [];
    kT_a_mu_ossz = [];
    kT_a_angleav_ossz = [];
    kT_a_anglestd_ossz = [];
    kT_a_anglezc_ossz = [];
    k_KontT1 = [];
    
    for j = 1:size(klat_msd_atlag, 2)
        jelenlegi_sejt = klat_msd_atlag{1, j};
    
        KontT1 = [];
    
        for g = 1:length(k_kezsv1)
            if strcmp(k_kont1{j}, k_kezsv1{g})
                KontT1 = g;
            end
        end
        k_KontT2 = find(k_knum == KontT1);
        k_KontT1 = [k_KontT1 k_KontT2];
    
        kT_a_elm_ossz = [kT_a_elm_ossz kT_elmozd_atlag(j)/kT_elmozd_atlag(KontT1)];
        kT_a_msd_ossz = [kT_a_msd_ossz kT_msd_atlag(j)/kT_msd_atlag(KontT1)];
        kT_a_maxe_ossz = [kT_a_maxe_ossz kT_maxe_atlag(j)/kT_maxe_atlag(KontT1)];
        kT_a_v_ossz = [kT_a_v_ossz kT_v_atlag(j)/kT_v_atlag(KontT1)];
        kT_a_av_ossz = [kT_a_av_ossz kAseb_atlag{j}/kAseb_atlag{KontT1}];
        kT_a_dr_ossz = [kT_a_dr_ossz kDR_atlag{j}/kDR_atlag{KontT1}];
        kT_a_mu_ossz = [kT_a_mu_ossz kT_mu_atlag(j)/kT_mu_atlag(KontT1)];
        kT_a_angleav_ossz = [kT_a_angleav_ossz kAngleav_atlag{j}/kAngleav_atlag{KontT1}];
        kT_a_anglestd_ossz = [kT_a_anglestd_ossz kAnglestd_atlag{j}/kAnglestd_atlag{KontT1}];
        kT_a_anglezc_ossz = [kT_a_anglezc_ossz kAnglezc_atlag{j}/kAnglezc_atlag{KontT1}];
    end
    
    kT_tf_elmozd = [];
    kT_tf_maxe = [];
    kT_tf_msd = [];
    kT_tf_mu = [];
    kT_tf_v = [];
    kT_tf_v_a = [];
    kT_tf_dr = [];
    kT_tf_angleav = [];
    kT_tf_anglestd = [];
    kT_tf_anglezc = [];
    
    kT_e_m = [];
    kT_e_sd = [];
    kT_maxe_m = [];
    kT_maxe_sd = [];
    kT_msd_m = [];
    kT_msd_sd = [];
    kT_mu_m = [];
    kT_mu_sd = [];
    kT_v_m = [];
    kT_v_sd = [];
    kT_av_m = [];
    kT_av_sd = [];
    kT_dr_m = [];
    kT_dr_sd = [];
    kT_angleav_m = [];
    kT_angleav_sd = [];
    kT_anglestd_m = [];
    kT_anglestd_sd = [];
    kT_anglezc_m = [];
    kT_anglezc_sd = [];
    
    for i = 1:size(kT_elmozd,2)
        jelen = k_KontT1(i);
    
        kT_e_m = [kT_e_m mean(kT_elmozd{1,i}, 2, 'omitnan')];
        kT_e_sd = [kT_e_sd std(kT_elmozd{1,i}, 0, 2, 'omitnan')];
        kT_maxe_m = [kT_maxe_m mean(kT_maxe{1,i}, 2, 'omitnan')];
        kT_maxe_sd = [kT_maxe_sd std(kT_maxe{1,i}, 0, 2, 'omitnan')];
        kT_msd_m = [kT_msd_m mean(kT_msd{1,i}, 2, 'omitnan')];
        kT_msd_sd = [kT_msd_sd std(kT_msd{1,i}, 0, 2, 'omitnan')];
        kT_mu_m = [kT_mu_m mean(kT_mu{1,i}, 2, 'omitnan')];
        kT_mu_sd = [kT_mu_sd std(kT_mu{1,i}, 0, 2, 'omitnan')];
        kT_v_m = [kT_v_m mean(kT_v{1,i}, 2, 'omitnan')];
        kT_v_sd = [kT_v_sd std(kT_v{1,i}, 0, 2, 'omitnan')];
        kT_av_m = [kT_av_m mean(kT_v_a{1,i}, 2, 'omitnan')];
        kT_av_sd = [kT_av_sd std(kT_v_a{1,i}, 0, 2, 'omitnan')];
        kT_dr_m = [kT_dr_m mean(kT_dr{1,i}, 2, 'omitnan')];
        kT_dr_sd = [kT_dr_sd std(kT_dr{1,i}, 0, 2, 'omitnan')];
        kT_angleav_m = [kT_angleav_m mean(kT_angleav{1,i}, 2, 'omitnan')];
        kT_angleav_sd = [kT_angleav_sd std(kT_angleav{1,i}, 0, 2, 'omitnan')];
        kT_anglestd_m = [kT_anglestd_m mean(kT_anglestd{1,i}, 2, 'omitnan')];
        kT_anglestd_sd = [kT_anglestd_sd std(kT_anglestd{1,i}, 0, 2, 'omitnan')];
        kT_anglezc_m = [kT_anglezc_m mean(kT_anglezc{1,i}, 2, 'omitnan')];
        kT_anglezc_sd = [kT_anglezc_sd std(kT_anglezc{1,i}, 0, 2, 'omitnan')];
    
        thr_e_j = thr_e{1,jelen};
        thr_msd_j = thr_msd{1,jelen};
        thr_maxe_j = thr_maxe{1,jelen};
        thr_mu_j = thr_mu{1,jelen};
        thr_v_j = thr_v{1,jelen};
        thr_v_a_j = thr_v_a{1,jelen};
        thr_dr_j = thr_dr{1,jelen};
        thr_angleav_j = thr_angleav{1,jelen};
        thr_anglestd_j = thr_anglestd{1,jelen};
        thr_anglezc_j = thr_anglezc{1,jelen};
        if kT_e_m(1,i) < min(thr_e_j) 
            kT_tf_elmozd = [kT_tf_elmozd -1];
        elseif kT_e_m(1,i) > max(thr_e_j) 
            kT_tf_elmozd = [kT_tf_elmozd 1];
        else
            kT_tf_elmozd = [kT_tf_elmozd 0];
        end
    
        if kT_maxe_m(1,i) < min(thr_maxe_j)
            kT_tf_maxe = [kT_tf_maxe -1];
        elseif kT_maxe_m(1,i) > max(thr_maxe_j)
            kT_tf_maxe = [kT_tf_maxe 1];
        else
            kT_tf_maxe = [kT_tf_maxe 0];
        end
    
        if kT_msd_m(1,i) < min(thr_msd_j)
            kT_tf_msd = [kT_tf_msd -1];
        elseif kT_msd_m(1,i) > max(thr_msd_j)
            kT_tf_msd = [kT_tf_msd 1];
        else
            kT_tf_msd = [kT_tf_msd 0];
        end
    
        if kT_mu_m(1,i) < min(thr_mu_j)
            kT_tf_mu = [kT_tf_mu -1];
        elseif kT_mu_m(1,i) > max(thr_mu_j)
            kT_tf_mu = [kT_tf_mu 1];
        else
            kT_tf_mu = [kT_tf_mu 0];
        end
    
        if kT_v_m(1,i) < min(thr_v_j)
            kT_tf_v = [kT_tf_v -1];
        elseif kT_v_m(1,i) > max(thr_v_j)
            kT_tf_v = [kT_tf_v 1];
        else
            kT_tf_v = [kT_tf_v 0];
        end
    
        if kT_av_m(1,i) < min(thr_v_a_j)
            kT_tf_v_a = [kT_tf_v_a -1];
        elseif kT_av_m(1,i) > max(thr_v_a_j)
            kT_tf_v_a = [kT_tf_v_a 1];
        else
            kT_tf_v_a = [kT_tf_v_a 0];
        end
    
        if kT_dr_m(1,i) < min(thr_dr_j)
            kT_tf_dr = [kT_tf_dr -1];
        elseif kT_dr_m(1,i) > max(thr_dr_j)
            kT_tf_dr = [kT_tf_dr 1];
        else
            kT_tf_dr = [kT_tf_dr 0];
        end

        if kT_angleav_m(1,i) < min(thr_angleav_j)
            kT_tf_angleav = [kT_tf_angleav -1];
        elseif kT_angleav_m(1,i) > max(thr_angleav_j)
            kT_tf_angleav = [kT_tf_angleav 1];
        else
            kT_tf_angleav = [kT_tf_angleav 0];
        end

        if kT_anglestd_m(1,i) < min(thr_anglestd_j)
            kT_tf_anglestd = [kT_tf_anglestd -1];
        elseif kT_anglestd_m(1,i) > max(thr_anglestd_j)
            kT_tf_anglestd = [kT_tf_anglestd 1];
        else
            kT_tf_anglestd = [kT_tf_anglestd 0];
        end

        if kT_anglezc_m(1,i) < min(thr_anglezc_j)
            kT_tf_anglezc = [kT_tf_anglezc -1];
        elseif kT_anglezc_m(1,i) > max(thr_anglezc_j)
            kT_tf_anglezc = [kT_tf_anglezc 1];
        else
            kT_tf_anglezc = [kT_tf_anglezc 0];
        end
    end

    %% Cell Trackeres kiertékeles - ugyanaz a séma mint a kézi kiértékelésnél

    ct_msd_ossz  ={};
    ct_maxelm_ossz = {};
    ct_v_atlag_ossz = {};
    ct_v_ossz = {};
    ct_megtettut_ossz = {};
    ct_elmozd_ossz = {};
    ct_megtettut_eddig = {};
    ct_ep_dr_ossz = {};
    ct_angleav_ossz = {};
    ct_anglestd_ossz = {};
    ct_anglezc_ossz = {};
    ct_alfa_ossz = {};
    ct_x_sejtek = {};
    ct_y_sejtek = {};
    
    ct_latoter = {};
    ct_nev ={};
    ct_sv = {};
    ct_kez ={};
    ct_kont = {};
    ct_t = {};
    ct_kezsv = {};
    ct_gep = {};
    ct_kontn = {};
    ossz_sejt = 0;

    ct_sv_h = {};
    ct_kez_h = {};
    ct_kont_h = {};
    ct_kezsv_h = {};

    filenevek = {};
    kivett_gyors = [];
    kivett_megallt = [];
    total_sejtek_ossz = [];
    maradt_sejtek_ossz = [];

    for j = 1:length(ossz_excel)
        z = [ossz_excel(j).folder, '\', ossz_excel(j).name];
        mostani_file = z;
        melyiksejtv = 0;
        jelenlegi_excel = ossz_excel(j).name;
        hanyas_excel = strsplit(jelenlegi_excel,'_');
        hanyas_e = strsplit(hanyas_excel{end},'.');
        ct_latoter{end+1} = str2double(hanyas_e{1});
        nev1 = strsplit(jelenlegi_excel,'.');
        ct_nev{end+1} = nev1{1};
        for h = 1:size(T,1)
            if strcmp(ct_nev{j}, T.nev{h})
                ct_sv{end+1} = T.sejtvonal{h};
                ct_kez{end+1} = T.kezeles{h};
                ct_gep{end+1} = T.gep{h};
                ct_kont{end+1} = append(T.sejtvonal{h}, ' ', T.kontroll{h}, ' ', T.gep{h});
                ct_kontn{end+1} = T.kontroll{h};
            end
        end
    
        ct_kezsv{end+1} = append(ct_sv{end}, ' ', ct_kez{end}, ' ', ct_gep{end});

        for kezisejtvonal = 1:size(k_kezsv1,2)
            if strcmp(k_kezsv1(kezisejtvonal), ct_kezsv(j))
                melyiksejtv = kezisejtvonal;
            end
        end
    
        if strcmp(ct_gep{end}, 'uj')
            t = 20; %20/2
        elseif strcmp(ct_gep{end}, 'regi')
            t = 15; % 15/3
        else
            t = 0;
        end
        
        ct_t{end+1} = t;
        uj = 20;
        ujh = 70;
        regi = 15;
        regih = 92;
                
        col_titles = {
            'file_name'
            'cell_count'
            'avg_path_length'
            'cnt_length_not_max'
            'osszes_megtett_ut' 
            'osszes_elmozdulas'};
    
        % Itt inicializálunk egy üres táblát
        sejtek_szama_fajlokban = array2table(zeros(0,numel(col_titles)));
        sejtek_szama_fajlokban.Properties.VariableNames = col_titles;
    
            % Itt történik a path fájl értelmezése
            xls = readtable(z);
            Y = table2array(xls(:,1));
            X = table2array(xls(:,2));
            Y1 = Y;
            X1 = X;
            CNT = table2array(xls(:,3));
            ID = table2array(xls(:,4));
    
            num_ID = unique(ID);
    
            Y_ment = Y;
            X_ment = X;
            
            % Hány elemből állnak az egyes követések:
            GC = groupcounts(ID);
            if  t == regi
                for f = 1:length(GC)
                    nm = [];
                    for x = 1:GC(f)
                        nm = [nm x];
                    end
                    nm = nm(1:3:end);
                    GC(f) = length(nm);
                end
            elseif t == uj
                for f = 1:length(GC)
                    nm = [];
                    for x = 1:GC(f)
                        nm = [nm x];
                    end
                    nm = nm(1:2:end);
                    GC(f) = length(nm);
                end
            end
            
      
    
            % Átlagszámítás
            avg_path_length = mean(GC);
    
            count_not_max = sum(GC ~= max(GC));
    
            osszes_megtett_ut = 0;
            osszes_elmozdulas = 0;
    
            %% Egyesével az útvonalak számolása - minden sejtre
    
            ep_dr_per_file = [];
            v_ossz_per_file = [];
            alfa_per_file = NaN(max(GC), numel(GC));
            angleav_per_file = [];
            anglestd_per_file = [];
            anglezc_per_file = [];
            maxelm_per_file = NaN(max(GC), numel(GC));
            v_per_file = NaN(max(GC), numel(GC));
            elmozd_per_file = NaN(max(GC), numel(GC));
            msd_per_file2 = NaN(max(GC), numel(GC));
            megtettut_eddig_per_file = NaN(max(GC), numel(GC));
            megtettut_per_file = NaN(max(GC), numel(GC));
    
            h = 0;

            gyors_count = 0;
            megallt_count = 0;
            total_sejtek = numel(unique(ID));

            for ez_a_sejt=0:max(ID)
                maszk = ID == ez_a_sejt;
    
                % zaj eredetű elmozdulások kiszedése
                Y_adott_sejtre = Y(ID==ez_a_sejt);
                X_adott_sejtre = X(ID==ez_a_sejt); 
                for n=2:size(Y_adott_sejtre)     
                   x_sejtre_elozo = X_adott_sejtre(n-1);
                   x_sejtre_most =  X_adott_sejtre(n);            
                   y_sejtre_elozo = Y_adott_sejtre(n-1);
                   y_sejtre_most =  Y_adott_sejtre(n);                       
                   ut_most = (sqrt( (x_sejtre_elozo - x_sejtre_most)^2 + ...
                                    (y_sejtre_elozo - y_sejtre_most)^2 ));            
                   if ut_most < epsilon 
                       % Ebben az esetben (nem számottevő az elmozdulás) az X és Y adott sejtre a korábbi koordinátákra cseréli.
                       Y_adott_sejtre(n) = Y_adott_sejtre(n-1);
                       X_adott_sejtre(n) = X_adott_sejtre(n-1);           
                   end                
                end
                % Adott sejtre - kipucolt X-et és Y-t visszatesszük a nagy X-be és nagy Y-ba
                Y(ID==ez_a_sejt) = Y_adott_sejtre;
                X(ID==ez_a_sejt) = X_adott_sejtre;
                % zajkiszedés vége

                if ~ismember(ez_a_sejt, ID)
                    h = h+1;
                    continue
                end
                
                x_sejtre = X(maszk);
                y_sejtre = Y(maszk);
                if t == regi
                    x_sejtre = x_sejtre(1:3:end);
                    y_sejtre = y_sejtre(1:3:end);
                elseif t == uj
                    x_sejtre = x_sejtre(1:2:end);
                    y_sejtre = y_sejtre(1:2:end);
                end
    
                ct_x_sejtek{end+1} = x_sejtre;
                ct_y_sejtek{end+1} = y_sejtre;

                % Halott sejt kiszededés
                Y_adott_sejtre = Y(ID==ez_a_sejt);
                X_adott_sejtre = X(ID==ez_a_sejt);
                ut_most_sejtre = [];
                for n=2:size(Y_adott_sejtre)     
                   x_sejtre_elozo = X_adott_sejtre(n-1);
                   x_sejtre_most =  X_adott_sejtre(n);            
                   y_sejtre_elozo = Y_adott_sejtre(n-1);
                   y_sejtre_most =  Y_adott_sejtre(n);                       
                   ut_most = (sqrt( (x_sejtre_elozo - x_sejtre_most)^2 + ...
                                    (y_sejtre_elozo - y_sejtre_most)^2 ));    
                   ut_most_sejtre = [ut_most_sejtre ut_most];             
                end
                
                % Feltételezzük:
                % ut_most_sejtre = vektor, adott sejt két időpont közötti elmozdulása
                % kut_most_2std_max = vektor, minden sejtvonalhoz max lépés (átlag+2SD)
                % melyiksejtv = index, hogy melyik sejtvonalról van szó
                % t = mérési intervallum percben (15 vagy 20)

                % Sebesség alapján halott (legalább 2 egymást követő lépés nagyobb mint a 2SD küszöb)
                gyors_hatar = kut_most_2std_max(melyiksejtv);
                if any( ut_most_sejtre(1:end-1) > gyors_hatar & ut_most_sejtre(2:end) > gyors_hatar )
                    gyors_count = gyors_count + 1;
                    X(ID==ez_a_sejt) = NaN;
                    Y(ID==ez_a_sejt) = NaN;
                    continue
                end

                
                % Megállás az utolsó 3 órában
                steps_back = (60/t)*3;
                if t == regi && size(x_sejtre,1) > regih || t == uj && size(x_sejtre,1) > ujh
                    if all(ut_most_sejtre(end-steps_back:end) == 0) 
                        megallt_count = megallt_count + 1;
                        X(ID==ez_a_sejt) = NaN;
                        Y(ID==ez_a_sejt) = NaN;
                        continue
                    end
                end
                % kiszed vége
                            
                
                ssz = ez_a_sejt - h;
                ssz_2 = ssz + 1;
                
                GCi = GC(ssz_2);
                
            %% Mozgasra jellemzo parameterek kiszamitasa
            
            % Megtett ut eddig (ket kep kozott), megtett ut - TTD
                megtett_ut_eddig = 0;
                megtett_ut_most_masolat = 0;
                megtett_ut = 0;
    
                if t == regi && size(x_sejtre,1) > regih || t == uj && size(x_sejtre,1) > ujh
                    for s =1:numel(x_sejtre)-1                     
                            megtett_ut_most = (sqrt( (x_sejtre(s+1)-x_sejtre(s))^2 + (y_sejtre(s+1)-y_sejtre(s))^2 ))*2.18;
                            megtett_ut_most_masolat(s) = megtett_ut_most;
                            megtett_ut = megtett_ut + megtett_ut_most;
                            megtett_ut_eddig(s) = megtett_ut;
                            megtettut_per_file(s, ssz_2) = megtett_ut_most_masolat(s);
                            megtettut_eddig_per_file(s, ssz_2) = megtett_ut_eddig(s);
                    end
                else
                end
                
    
            % Elmozdulas - D és maximális elmozdulás - MaxD
                maxelm = 0;
                if t == regi && size(x_sejtre,1) > regih || t == uj && size(x_sejtre,1) > ujh
                    for i = 1:GCi
                        elmozd_per_file(i, ssz_2) = (sqrt( (x_sejtre(i)-x_sejtre(1))^2 + (y_sejtre(i)-y_sejtre(1))^2 ))*2.18; 
                        elmozdulas = elmozd_per_file(i, ssz_2);
                        if ~isnan(elmozdulas) && maxelm < elmozdulas
                            maxelm = elmozdulas;
                        elseif isnan(elmozdulas)
                            maxelm = elmozdulas;
                        end
                        maxelm_per_file(i, ssz_2) = maxelm;
                    end
                end
    
            % Directionality ratio - DR
                if ~isnan(elmozd_per_file(1, ssz_2))
                    ep_dr = elmozdulas/megtett_ut;
                else
                    ep_dr = elmozd_per_file(1, ssz_2);
                end
                    ep_dr_per_file = [ep_dr_per_file, ep_dr];
    
    
            % Mean squared displacement-MSD = (1/N-n) * sum egytol N-n-ig (d^2(pi,pi+n) -- n=1:GCi
                msd_per_file = NaN(max(GC), max(GC));
                if t == regi && size(x_sejtre,1) > regih || t == uj && size(x_sejtre,1) > ujh
                    for n = 1:GCi-1
                        for i = 1:GCi-n                        
                            d2 = (x_sejtre(i+n)-x_sejtre(i))^2 + (y_sejtre(i+n)-y_sejtre(i))^2;
                            d2 = sqrt(d2) * 2.18; %% PX -> um
                            msd_per_file(i,n) = d2;        
                        end                    
                    end
                    msd_per_file = reshape(permute(msd_per_file, [1,3,2]), size(msd_per_file, 3)*size(msd_per_file, 1), size(msd_per_file, 2))';
        
                    darabteli = ~isnan(msd_per_file);
                    darabteli = sum(darabteli, 2);
        
                    msd_per_file2(:,ssz_2) = mean(msd_per_file, 2, 'omitnan');
                else
                end
    
            % Turning angle - alfa = tan^-1[yi+1-y1)-(xi+1-x1)] + átlag ATA
    
            alfa = [];
            if t == regi && size(x_sejtre, 1) > regih || t == uj && size(x_sejtre, 1) > ujh
                for i = 1:GCi-1                
                    delta_x = x_sejtre(i+1) - x_sejtre(i);
                    delta_y = y_sejtre(i+1) - y_sejtre(i);
                    alfa(i) = atan2(delta_y, delta_x);
                    alfa(i) = rad2deg(alfa(i));
                    if alfa(i) < 0
                        alfa(i) = alfa(i) + 360;
                    end
                    alfa_per_file(i, ssz_2) = alfa(i);
                end
            end

            angleav_per_file = mean(alfa_per_file, 1, 'omitnan');
            anglestd_per_file = std(alfa_per_file, 0, 1, 'omitnan');

            % Zero-crossing detektálása – körkörös szögkülönbségek alapján -TVZC
            anglezc_per_file = zeros(1, size(alfa_per_file, 2));

            for f = 1:size(alfa_per_file, 2)
                angles = alfa_per_file(:,f);
                dtheta = mod(diff(angles) + 180, 360) - 180;
                sign_change = sign(dtheta(1:end-1)) ~= sign(dtheta(2:end));
                valid = (sign(dtheta(1:end-1)) ~= 0) & (sign(dtheta(2:end)) ~= 0);

                anglezc_per_file(f) = sum(sign_change & valid);
            end


            % Velocity - V = d(pi, pi+1)/delta t  + atlag
                v = [];
                if t == regi && size(x_sejtre,1) > regih || t == uj && size(x_sejtre,1) > ujh
                    for i = 1:GCi-1                
                        v(i) = ((sqrt( (x_sejtre(i+1)-x_sejtre(i))^2 + (y_sejtre(i+1)-y_sejtre(i))^2 ))/t(end))*2.18;
                        v_per_file(i, ssz_2) = v(i);
                    end
                else
                end
                v_atlag = mean(v_per_file(:, ssz_2), 1, 'omitnan');
                v_ossz_per_file = [v_ossz_per_file, v_atlag];
    
    
                osszes_megtett_ut = osszes_megtett_ut + (megtett_ut * GC(ssz_2));
                osszes_elmozdulas = osszes_elmozdulas + (elmozdulas * GC(ssz_2));
    
            end
            
            % Elmozdulas, megtett ut atlag
            osszes_megtett_ut = osszes_megtett_ut / sum(GC);  
            osszes_elmozdulas = osszes_elmozdulas / sum(GC);
    
            sejtek_szama = length(num_ID);
    
            ossz_sejt = ossz_sejt + sejtek_szama;
            % Adott parameterek kiirasa tablazatba
            mostani_sor = table({ ...
                mostani_file}, ...
                sejtek_szama, ...
                avg_path_length, ...
                count_not_max, ...
                osszes_megtett_ut, ...
                osszes_elmozdulas, ...
                'VariableNames', col_titles);
    
            sejtek_szama_fajlokban = [sejtek_szama_fajlokban;mostani_sor];
                
        %% Mozgasra jellemzo parameterek osszes sejtre
    
            % Külön tisztítás mindegyik mátrixra
            maxelm_per_file = maxelm_per_file(:, ~all(isnan(maxelm_per_file),1));
            msd_per_file2   = msd_per_file2(:, ~all(isnan(msd_per_file2),1));
            v_ossz_per_file = v_ossz_per_file(:, ~all(isnan(v_ossz_per_file),1));
            v_per_file      = v_per_file(:, ~all(isnan(v_per_file),1));
            megtettut_per_file = megtettut_per_file(:, ~all(isnan(megtettut_per_file),1));
            elmozd_per_file = elmozd_per_file(:, ~all(isnan(elmozd_per_file),1));
            megtettut_eddig_per_file = megtettut_eddig_per_file(:, ~all(isnan(megtettut_eddig_per_file),1));
            ep_dr_per_file  = ep_dr_per_file(:, ~all(isnan(ep_dr_per_file),1));
            alfa_per_file   = alfa_per_file(:, ~all(isnan(alfa_per_file),1));
            angleav_per_file = angleav_per_file(:, ~all(isnan(angleav_per_file),1));
            anglestd_per_file= anglestd_per_file(:, ~all(isnan(anglestd_per_file),1));
            anglezc_per_file = anglezc_per_file(:, ~all(isnan(anglezc_per_file),1));

    
        % Összes parameter az összes file-ra
            ct_msd_ossz{end+1} = msd_per_file2;
            ct_maxelm_ossz{end+1} = maxelm_per_file;
            ct_v_atlag_ossz{end+1} = v_ossz_per_file;
            ct_v_ossz{end+1} = v_per_file;
            ct_megtettut_ossz{end+1} = megtettut_per_file;
            ct_elmozd_ossz{end+1} = elmozd_per_file;
            ct_megtettut_eddig{end+1} = megtettut_eddig_per_file;
            ct_ep_dr_ossz{end+1} = ep_dr_per_file;
            ct_alfa_ossz{end+1} = alfa_per_file;
            ct_angleav_ossz{end+1} = angleav_per_file;
            ct_anglestd_ossz{end+1} = anglestd_per_file;
            ct_anglezc_ossz{end+1} = anglezc_per_file;
            filenevek{end+1} = jelenlegi_excel;
            kivett_gyors(end+1) = gyors_count;
            kivett_megallt(end+1) = megallt_count;
            total_sejtek_ossz(end+1) = total_sejtek;
            maradt_sejtek_ossz(end+1) = total_sejtek - (gyors_count + megallt_count);

            
        %    Halottsejt kiírás a parancssorba
        % fprintf('Fájl: %s | Összes sejt: %d | Gyors: %d | Megállt: %d | Maradt: %d\n', ...
        %     jelenlegi_excel, total_sejtek, gyors_count, megallt_count, ...
        %     total_sejtek - gyors_count - megallt_count);
        validCols = ~all(isnan(maxelm_per_file),1);   % csak azok az oszlopok, ahol van adat
        if any(validCols)
            ct_sv_h{end+1} = ct_sv{j};
            ct_kez_h{end+1} = ct_kez{j};
            ct_kont_h{end+1} = ct_kont{j};
            ct_kezsv_h{end+1} = ct_kezsv{j};
        end

    end

    % ct_sv = ct_sv_h;
    % ct_kez = ct_kez_h;
    % ct_konz = ct_kont_h;
    % ct_kezsv = ct_kezsv_h;
    
    % Halottsejt kiírás a parancssorba
    % Table1 = table(filenevek', total_sejtek_ossz', kivett_gyors', kivett_megallt', maradt_sejtek_ossz', ...
    %     'VariableNames', {'Fajl', 'Összes sejt', 'GyorsHalott', 'MegalltHalott', 'Megmaradt sejtek'});
    % writetable(Table1, 'halottsejtek.xls', 'WriteMode', 'append');

    % disp(table(filenevek', total_sejtek_ossz', kivett_gyors', kivett_megallt', maradt_sejtek_ossz', ...
    %     'VariableNames', {'Fajl', 'Összes sejt', 'GyorsHalott', 'MegalltHalott', 'Megmaradt sejtek'}));
    
    % Ábra – összes kivett sejt fájlonként
    osszes_kivett = kivett_gyors + kivett_megallt;
    figure;
    bar(osszes_kivett);
    set(gca, 'XTickLabel', filenevek, 'XTickLabelRotation', 45);
    ylabel('Kivett sejtek száma');
    title('Halott sejtek fájlonként');

    %% Két pont közötti távolság eloszlása
    
    ct_mu_eddig = NaN(100, ossz_sejt);
    ct_mu_eddig_v = [];
    c = 1;
    for k = 1:size(ct_megtettut_ossz,2)
        jelenlegi = ct_megtettut_ossz{1,k};
        for f = 1:size(jelenlegi,2)
            sorh = size(jelenlegi,1);
            ct_mu_eddig(1:sorh,c) = jelenlegi(:,f);
            c = c + 1;
            ct_mu_eddig_v = [ct_mu_eddig_v; jelenlegi(:,f)];
        end
    end
    
    %% Histogram
    
    % h = histogram(ct_mu_eddig_v,'BinWidth',2);
    % p = histcounts(ct_mu_eddig_v,'BinWidth',2,'Normalization','pdf');
    % 
    % figure
    % histogram(ct_mu_eddig_v,'BinWidth',2, 'Normalization','pdf');
    % hold on
    % binCenters = h.BinEdges + (h.BinWidth/2);
    % plot(binCenters(1:end-1), p, 'r-','LineWidth',1.5)
    
    
    %% Cell tracker - megkeressük, hogy melyik sejtvonal melyik kezelések tartoznak egybe - átlag, szórás is

    kezsv_masolat = ct_kezsv;
    atlagolando = {};
    for i = 1:size(ct_kezsv, 2)
        valtozo1 = [];
        for j = 1:size(kezsv_masolat, 2)
            km = kezsv_masolat{j};
            if km ~= 0
                if strcmp(ct_kezsv{i}, kezsv_masolat{j})
                    valtozo1(end+1) = j;
                    kezsv_masolat{j} = 0;
                end
            end
        end
        if ~isempty(valtozo1)
            atlagolando{end+1} = valtozo1;
        end
    end
    
    
    ctEl_atlag = {};
    ctEl_szoras = {};
    ctMu_atlag = {};
    ctMu_szoras = {};
    ctDR_atlag = {};
    ctDR_szoras = {};
    ctSeb_atlag = {};
    ctSeb_szoras = {};
    ctAseb_atlag = {};
    ctAseb_szoras = {};
    ctMaxe_atlag = {};
    ctMaxe_szoras = {};
    ctMSD_atlag = {};
    ctMSD_szoras = {};
    ctAngleav_atlag = {};
    ctAngleav_szoras = {};
    ctAnglestd_atlag = {};
    ctAnglestd_szoras = {};
    ctAnglezc_atlag = {};
    ctAnglezc_szoras = {};
    ct_kezsv1 = {};
    ct_kez1 = {};
    ct_kont1 = {};
    ct_sv1 = {};
    ct_gep1 = {};
    ct_t1 = {};
    ct_ltn = {};
    
    ctlat_elmozd_atlag = {};
    ctlat_megtettut_eddig = {};
    ctlat_ep_dr_atlag = {};
    ctlat_v_atlag = {};
    ctlat_v_atlag_atlag = {};
    ctlat_maxelm_atlag = {};
    ctlat_msd_atlag = {};
    ctlat_angleav_atlag = {};
    ctlat_anglestd_atlag = {};
    ctlat_anglezc_atlag = {};
    
    for j = 1:size(atlagolando, 2)
    
        if length(atlagolando{j}) >= 1
            latt = [];
            ctEl = {};
            ctMu = {};
            ctDR = {};
            ctSeb = {};
            ctAseb = {};
            ctMaxe = {};
            ctMSD = {};
            ctAngleav = {};
            ctAnglestd = {};
            ctAnglezc = {};

            parhuzamosok = atlagolando{1, j};
            for i = 1:length(parhuzamosok)
                ctEl{end+1} = ct_elmozd_ossz{parhuzamosok(i)};
                ctMu{end+1} = ct_megtettut_eddig{parhuzamosok(i)};
                ctDR{end+1} = ct_ep_dr_ossz{parhuzamosok(i)};
                ctSeb{end+1} = ct_v_ossz{parhuzamosok(i)};
                ctAseb{end+1} = ct_v_atlag_ossz{parhuzamosok(i)};
                ctMaxe{end+1} = ct_maxelm_ossz{parhuzamosok(i)};
                ctMSD{end+1} = ct_msd_ossz{parhuzamosok(i)};
                ctAngleav{end+1} = ct_angleav_ossz{parhuzamosok(i)};
                ctAnglestd{end+1} = ct_anglestd_ossz{parhuzamosok(i)};
                ctAnglezc{end+1} = ct_anglezc_ossz{parhuzamosok(i)};
    
            end
            ctlat_elmozd_atlag{end+1} = cell2mat(ctEl);
            ctEl_atlag{end+1} = mean(cell2mat(ctEl), 2, 'omitnan');
            ctEl_szoras{end+1} = std(cell2mat(ctEl), 0, 2, 'omitnan')/sqrt(size(cell2mat(ctEl),2));
            ctlat_megtettut_eddig{end+1} = cell2mat(ctMu);
            ctMu_atlag{end+1} = mean(cell2mat(ctMu), 2, 'omitnan');
            ctMu_szoras{end+1} = std(cell2mat(ctMu), 0, 2, 'omitnan')/sqrt(size(cell2mat(ctMu),2));
            ctlat_ep_dr_atlag{end+1} = cell2mat(ctDR);
            ctDR_atlag{end+1} = mean(cell2mat(ctDR), 2, 'omitnan');
            ctDR_szoras{end+1} = (std(cell2mat(ctDR), 0, 2, 'omitnan')/mean(cell2mat(ctAseb), 2, 'omitnan'))*100;
            ctlat_v_atlag{end+1} = cell2mat(ctSeb);
            ctSeb_atlag{end+1} = mean(cell2mat(ctSeb), 2, 'omitnan');
            ctSeb_szoras{end+1} = std(cell2mat(ctSeb), 0, 2, 'omitnan')/sqrt(size(cell2mat(ctSeb),2));
            ctlat_v_atlag_atlag{end+1} = cell2mat(ctAseb);
            ctAseb_atlag{end+1} = mean(cell2mat(ctAseb), 2, 'omitnan');
            ctAseb_szoras{end+1} = (std(cell2mat(ctAseb), 0, 2, 'omitnan')/mean(cell2mat(ctAseb), 2, 'omitnan'))*100;
            ctlat_maxelm_atlag{end+1} = cell2mat(ctMaxe);
            ctMaxe_atlag{end+1} = mean(cell2mat(ctMaxe), 2, 'omitnan');
            ctMaxe_szoras{end+1} = std(cell2mat(ctMaxe), 0, 2, 'omitnan')/sqrt(size(cell2mat(ctMaxe),2));
            ctlat_msd_atlag{end+1} = cell2mat(ctMSD);
            ctMSD_atlag{end+1} = mean(cell2mat(ctMSD), 2, 'omitnan');
            ctMSD_szoras{end+1} = std(cell2mat(ctMSD), 0, 2, 'omitnan')/sqrt(size(cell2mat(ctMSD),2));
            ctlat_angleav_atlag{end+1} = cell2mat(ctAngleav);
            ctAngleav_atlag{end+1} = mean(cell2mat(ctAngleav), 2, 'omitnan');
            ctAngleav_szoras{end+1} = (std(cell2mat(ctAngleav), 0, 2, 'omitnan')/mean(cell2mat(ctAngleav), 2, 'omitnan'))*100;
            ctlat_anglestd_atlag{end+1} = cell2mat(ctAnglestd);
            ctAnglestd_atlag{end+1} = mean(cell2mat(ctAnglestd), 2, 'omitnan');
            ctAnglestd_szoras{end+1} = (std(cell2mat(ctAnglestd), 0, 2, 'omitnan')/mean(cell2mat(ctAnglestd), 2, 'omitnan'))*100;
            ctlat_anglezc_atlag{end+1} = cell2mat(ctAnglezc);
            ctAnglezc_atlag{end+1} = mean(cell2mat(ctAnglezc), 2, 'omitnan');
            ctAnglezc_szoras{end+1} = (std(cell2mat(ctAnglezc), 0, 2, 'omitnan')/mean(cell2mat(ctAnglezc), 2, 'omitnan'))*100;


            latt = sum(latt);
            elso = parhuzamosok(1);
            ct_kezsv1{end+1} = ct_kezsv{elso};
            ct_kez1{end+1} = ct_kez{elso};
            ct_kont1{end+1} = ct_kont{elso};
            ct_sv1{end+1} = ct_sv{elso};
            ct_gep1{end+1} = ct_gep{elso};
            ct_t1{end+1} = ct_t{elso};
            ct_ltn{end+1} = size(ctlat_elmozd_atlag{j},2);
    
        end
    end
    
    %% Kontroll gorbe allatti teruletenek kiszamolasa (AUC)
    
    ctMaxT_elmozd = {};
    ctMinT_elmozd = {};
    ctMaxT_msd = {};
    ctMinT_msd = {};
    ctMaxT_v = {};
    ctMinT_v = {};
    ctMaxT_v_a = {};
    ctMinT_v_a = {};
    ctMaxT_mu = {};
    ctMinT_mu = {};
    ctMaxT_maxe = {};
    ctMinT_maxe = {};
    ctMaxT_dr = {};
    ctMinT_dr = {};
    ctMaxT_angleav = {};
    ctMinT_angleav = {};
    ctMaxT_anglestd = {};
    ctMinT_anglestd = {};
    ctMaxT_anglezc = {};
    ctMinT_anglezc = {};
    
    ct_ksv = {};
    ct_kgep = {};
    ct_kkezsv = {};
    ct_knum = [];
    ct_svk = {};
    ct_gepk = {};
    ct_kezsvk = {};
    ct_numk = [];
    ct_ltn1 = {};
    
    for j = 1:size(atlagolando, 2)
        jelenlegi_sejt = atlagolando{1, j};
        ctMaxT_elmozd1 = [];
        ctMinT_elmozd1 = [];
        ctMaxT_msd1 = [];
        ctMinT_msd1 = [];
        ctMaxT_v1 = [];
        ctMinT_v1 = [];
        ctMaxT_v_a1 = [];
        ctMinT_v_a1 = [];
        ctMaxT_mu1 = [];
        ctMinT_mu1 = [];
        ctMaxT_maxe1 = [];
        ctMinT_maxe1 = [];
        ctMaxT_dr1 = [];
        ctMinT_dr1 = [];
        ctMaxT_angleav1 = [];
        ctMinT_angleav1 = [];
        ctMaxT_anglestd1 = [];
        ctMinT_anglestd1 = [];
        ctMaxT_anglezc1 = [];
        ctMinT_anglezc1 = [];
        for h = 1:length(jelenlegi_sejt)
            jelen = ct_kezsv{jelenlegi_sejt(h)};
            hanysejt = ct_maxelm_ossz{1,jelenlegi_sejt(h)};
            if ~isempty(hanysejt)
                if strcmp(ct_kez1{j}, 'kont') || strcmp(ct_kez1{j}, 'kont 5%') || strcmp(ct_kez1{j}, 'GFP') || strcmp(ct_kez1{j}, 'mock') || strcmp(ct_kez1{j}, 'scram') || strcmp(ct_kez1{j}, 'scraml')
                    if h == 1
                        ct_ksv{end+1} = ct_sv1{j};
                        ct_kgep{end+1} = ct_gep1{j};
                        ct_kkezsv{end+1} = ct_kezsv1{j};
                        ct_knum = [ct_knum j];
                    end
    
                            % minden kapcsolódó mátrix oszlopszámát külön megnézzük
                        eo   = ct_elmozd_ossz{1, jelenlegi_sejt(h)};
                        msdo = ct_msd_ossz{1, jelenlegi_sejt(h)};
                        vo   = ct_v_ossz{1, jelenlegi_sejt(h)};
                        vao  = ct_v_atlag_ossz{jelenlegi_sejt(h)};
                        muo  = ct_megtettut_eddig{1, jelenlegi_sejt(h)};
                        maxeo= ct_maxelm_ossz{1, jelenlegi_sejt(h)};
                        dro  = ct_ep_dr_ossz{jelenlegi_sejt(h)};
                        angleavo  = ct_angleav_ossz{jelenlegi_sejt(h)};
                        anglestdo = ct_anglestd_ossz{jelenlegi_sejt(h)};
                        anglezco  = ct_anglezc_ossz{jelenlegi_sejt(h)};
                    
                        % maximum közös oszlopszám
                        maxCols = min([
                            size(hanysejt, 2), size(eo, 2), size(msdo, 2), ...
                            size(vo, 2), size(vao, 2), size(muo, 2), size(maxeo, 2), ...
                            size(dro, 2), size(angleavo, 2), size(anglestdo, 2), size(anglezco, 2)
                        ]);
                        % maxCols = size(hanysejt, 2);  % itt tényleg a cellán belül lévő mátrix mérete
                        for k = 1:maxCols
                            if all(isnan(hanysejt(:,k)))
                                continue;  % ha az egész oszlop NaN, ugorja át
                            end
                            
                            eo = ct_elmozd_ossz{1,jelenlegi_sejt(h)};
                            max_e = max(ctEl_atlag{:,j},eo(:,k));
                            max_e = max_e(~isnan(max_e));
                            min_e = min(ctEl_atlag{:,j},eo(:,k));
                            min_e = min_e(~isnan(min_e));
                            ctMaxT_elmozd1 = [ctMaxT_elmozd1 trapz(max_e)];
                            ctMinT_elmozd1 = [ctMinT_elmozd1 trapz(min_e)];
                
                            msdo = ct_msd_ossz{1,jelenlegi_sejt(h)};
                            max_msd = max(ctMSD_atlag{:,j},msdo(:,k));
                            max_msd = max_msd(~isnan(max_msd));
                            min_msd = min(ctMSD_atlag{:,j},msdo(:,k));
                            min_msd = min_msd(~isnan(min_msd));
                            ctMaxT_msd1 = [ctMaxT_msd1 trapz(max_msd)];
                            ctMinT_msd1 = [ctMinT_msd1 trapz(min_msd)];
                
                            vo = ct_v_ossz{1,jelenlegi_sejt(h)};
                            max_v = max(ctSeb_atlag{:,j},vo(:,k));
                            max_v = max_v(~isnan(max_v));
                            min_v = min(ctSeb_atlag{:,j},vo(:,k));
                            min_v = min_v(~isnan(min_v));
                            ctMaxT_v1 = [ctMaxT_v1 trapz(max_v)];
                            ctMinT_v1 = [ctMinT_v1 trapz(min_v)];
                
                            vao = ct_v_atlag_ossz{jelenlegi_sejt(h)};
                            ctMaxT_v_a1 = [ctMaxT_v_a1 max(mean(ctlat_v_atlag_atlag{1,j}, 2, 'omitnan'),vao(:,k))];
                            ctMinT_v_a1 = [ctMinT_v_a1 min(mean(ctlat_v_atlag_atlag{1,j}, 2, 'omitnan'),vao(:,k))];
            
                            muo = ct_megtettut_eddig{1,jelenlegi_sejt(h)};
                            max_mu = max(ctMu_atlag{:,j},muo(:,k));
                            max_mu = max_mu(~isnan(max_mu));
                            min_mu = min(ctMu_atlag{:,j},muo(:,k));
                            min_mu = min_mu(~isnan(min_mu));
                            ctMaxT_mu1 = [ctMaxT_mu1 trapz(max_mu)];
                            ctMinT_mu1 = [ctMinT_mu1 trapz(min_mu)];
                
                            maxeo = ct_maxelm_ossz{1,jelenlegi_sejt(h)};
                            max_maxe = max(ctMaxe_atlag{:,j},maxeo(:,k));
                            max_maxe = max_maxe(~isnan(max_maxe));
                            min_maxe = min(ctMaxe_atlag{:,j},maxeo(:,k));
                            min_maxe = min_maxe(~isnan(min_maxe));
                            ctMaxT_maxe1 = [ctMaxT_maxe1 trapz(max_maxe)];
                            ctMinT_maxe1 = [ctMinT_maxe1 trapz(min_maxe)];
                                
                            dro = ct_ep_dr_ossz{jelenlegi_sejt(h)};
                            ctMaxT_dr1 = [ctMaxT_dr1 max(mean(ctlat_ep_dr_atlag{1,j}, 2, 'omitnan'),dro(:,k))];
                            ctMinT_dr1 = [ctMinT_dr1 min(mean(ctlat_ep_dr_atlag{1,j}, 2, 'omitnan'),dro(:,k))];
        
                            angleavo = ct_angleav_ossz{jelenlegi_sejt(h)};
                            ctMaxT_angleav1 = [ctMaxT_angleav1 max(mean(ctlat_angleav_atlag{1,j}, 2, 'omitnan'),angleavo(:,k))];
                            ctMinT_angleav1 = [ctMinT_angleav1 min(mean(ctlat_angleav_atlag{1,j}, 2, 'omitnan'),angleavo(:,k))];
        
                            anglestdo = ct_anglestd_ossz{jelenlegi_sejt(h)};
                            ctMaxT_anglestd1 = [ctMaxT_anglestd1 max(mean(ctlat_anglestd_atlag{1,j}, 2, 'omitnan'),anglestdo(:,k))];
                            ctMinT_anglestd1 = [ctMinT_anglestd1 min(mean(ctlat_anglestd_atlag{1,j}, 2, 'omitnan'),anglestdo(:,k))];
        
                            anglezco = ct_anglezc_ossz{jelenlegi_sejt(h)};
                            ctMaxT_anglezc1 = [ctMaxT_anglezc1 max(mean(ctlat_anglezc_atlag{1,j}, 2, 'omitnan'),anglezco(:,k))];
                            ctMinT_anglezc1 = [ctMinT_anglezc1 min(mean(ctlat_anglezc_atlag{1,j}, 2, 'omitnan'),anglezco(:,k))];
                        end  
    
                else
                    if h == 1
                        ct_svk{end+1} = ct_sv1{j};
                        ct_gepk{end+1} = ct_gep1{j};
                        ct_kezsvk{end+1} = ct_kezsv1{j};
                        ct_numk = [ct_numk j];
                        ct_ltn1{end+1} = ct_ltn{j};
                    end
                end
            end
        end
        if ~isempty(ctMaxT_elmozd1)
            ctMaxT_elmozd{end+1} = ctMaxT_elmozd1;
            ctMinT_elmozd{end+1} = ctMinT_elmozd1;
            ctMaxT_msd{end+1} = ctMaxT_msd1;
            ctMinT_msd{end+1} = ctMinT_msd1;
            ctMaxT_v{end+1} = ctMaxT_v1;
            ctMinT_v{end+1} = ctMinT_v1;
            ctMaxT_v_a{end+1} = ctMaxT_v_a1;
            ctMinT_v_a{end+1} = ctMinT_v_a1;
            ctMaxT_mu{end+1} = ctMaxT_mu1;
            ctMinT_mu{end+1} = ctMinT_mu1;
            ctMaxT_maxe{end+1} = ctMaxT_maxe1;
            ctMinT_maxe{end+1} = ctMinT_maxe1;
            ctMaxT_dr{end+1} = ctMaxT_dr1;
            ctMinT_dr{end+1} = ctMinT_dr1;
            ctMaxT_angleav{end+1} = ctMaxT_angleav1;
            ctMinT_angleav{end+1} = ctMinT_angleav1;
            ctMaxT_anglestd{end+1} = ctMaxT_anglestd1;
            ctMinT_anglestd{end+1} = ctMinT_anglestd1;
            ctMaxT_anglezc{end+1} = ctMaxT_anglezc1;
            ctMinT_anglezc{end+1} = ctMinT_anglezc1;
        end
    end
    clear ctMaxT_elmozd1 ctMinT_elmozd1 ctMaxT_msd1 ctMinT_msd1 ctMaxT_v1 ctMinT_v1 ctMaxT_v_a1 ctMinT_v_a1 ctMaxT_mu1 ctMinT_mu1 ctMaxT_maxe1 ctMinT_maxe1 ctMaxT_dr1 ctMinT_dr1 ctMaxT_angleav1 ctMinT_angleav1 ctMaxT_anglezc1 ctMinT_anglezc1 ctMaxT_anglestd1 ctMinT_anglestd1
    
    ct_kT_elmozd = {};
    ct_kT_msd = {};
    ct_kT_v = {};
    ct_kT_v_a = {};
    ct_kT_mu = {};
    ct_kT_maxe = {};
    ct_kT_dr = {};
    ct_kT_angleav = {};
    ct_kT_anglestd = {};
    ct_kT_anglezc = {};
    
    ctT_elmozd_atlag = [];
    ctT_msd_atlag = [];
    ctT_v_atlag = [];
    ctT_mu_atlag = [];
    ctT_maxe_atlag = [];
    
    ctT_elmozd_lat_szor = [];
    ctT_msd_lat_szor = [];
    ctT_v_lat_szor = [];
    ctT_mu_lat_szor = [];
    ctT_maxe_lat_szor = [];
    
    for j = 1:size(ct_kezsv1,2)
        ctT_elmozd_lat = [];
        ctT_msd_lat = [];
        ctT_v_lat = [];
        ctT_mu_lat = [];
        ctT_maxe_lat = [];
    
        msdatlagideig = ctMSD_atlag{:,j};
        MSD_atlag_ideig = msdatlagideig(1:end-1);
        sebatlagideig = ctSeb_atlag{:,j};
        Seb_atlag__ideig = sebatlagideig(1:end-1);
        muatlagideig = ctMu_atlag{:,j};
        Mu_atlag_ideig = muatlagideig(1:end-1);
        
        ctT_elmozd_atlag = [ctT_elmozd_atlag trapz(ctEl_atlag{j})];
        ctT_msd_atlag = [ctT_msd_atlag trapz(MSD_atlag_ideig)];
        ctT_v_atlag = [ctT_v_atlag trapz(Seb_atlag__ideig)];
        ctT_mu_atlag = [ctT_mu_atlag trapz(Mu_atlag_ideig)];
        ctT_maxe_atlag = [ctT_maxe_atlag trapz(ctMaxe_atlag{j})];
        for i = 1:size(ctlat_elmozd_atlag{j},2)
            ctT_elmozd_lat = [ctT_elmozd_lat trapz(ctlat_elmozd_atlag{1,j}(:,i))];
            ctT_msd_lat = [ctT_msd_lat trapz(ctlat_msd_atlag{1,j}(1:end-1,i))];
            ctT_v_lat = [ctT_v_lat trapz(ctlat_v_atlag{1,j}(1:end-1,i))];
            ctT_mu_lat = [ctT_mu_lat trapz(ctlat_megtettut_eddig{1,j}(1:end-1,i))];
            ctT_maxe_lat = [ctT_maxe_lat trapz(ctlat_maxelm_atlag{1,j}(:,i))];
        end
        ctT_elmozd_lat_szor = [ctT_elmozd_lat_szor (std(ctT_elmozd_lat, 'omitnan')/mean(ctT_elmozd_lat, 'omitnan'))*100];
        ctT_msd_lat_szor = [ctT_msd_lat_szor (std(ctT_msd_lat, 'omitnan')/mean(ctT_msd_lat, 'omitnan'))*100];
        ctT_v_lat_szor = [ctT_v_lat_szor (std(ctT_v_lat, 'omitnan')/mean(ctT_v_lat, 'omitnan'))*100];
        ctT_mu_lat_szor = [ctT_mu_lat_szor (std(ctT_mu_lat, 'omitnan')/mean(ctT_mu_lat, 'omitnan'))*100];
        ctT_maxe_lat_szor = [ctT_maxe_lat_szor (std(ctT_maxe_lat, 'omitnan')/mean(ctT_maxe_lat, 'omitnan'))*100];
    end
    
    for i = 1:size(ct_kkezsv,2)
        ct_kT_elmozd1 = [];
        ct_kT_msd1 = [];
        ct_kT_v1 = [];
        ct_kT_v_a1 = [];
        ct_kT_mu1 = [];
        ct_kT_maxe1 = [];
        ct_kT_dr1 = [];
        ct_kT_angleav1 = [];
        ct_kT_anglestd1 = [];
        ct_kT_anglezc1 = [];
        for j = 1:size(ct_kezsv1,2)
            if strcmp(ct_kkezsv{i}, ct_kezsv1{j})
                maxCols = min([
                    size(ctMaxT_elmozd{i}, 2), ...
                    size(ctMinT_elmozd{1,i}, 2), ...
                    size(ctMaxT_msd{1,i}, 2), ...
                    size(ctMinT_msd{1,i}, 2), ...
                    size(ctMaxT_v{1,i}, 2), ...
                    size(ctMinT_v{1,i}, 2), ...
                    size(ctMaxT_v_a{1,i}, 2), ...
                    size(ctMinT_v_a{1,i}, 2), ...
                    size(ctMaxT_mu{1,i}, 2), ...
                    size(ctMinT_mu{1,i}, 2), ...
                    size(ctMaxT_maxe{1,i}, 2), ...
                    size(ctMinT_maxe{1,i}, 2), ...
                    size(ctMaxT_dr{1,i}, 2), ...
                    size(ctMinT_dr{1,i}, 2), ...
                    size(ctMaxT_angleav{1,i}, 2), ...
                    size(ctMinT_angleav{1,i}, 2), ...
                    size(ctMaxT_anglestd{1,i}, 2), ...
                    size(ctMinT_anglestd{1,i}, 2), ...
                    size(ctMaxT_anglezc{1,i}, 2), ...
                    size(ctMinT_anglezc{1,i}, 2)
                ]);
                for h = 1:maxCols

                % for h = 1:size(ctMaxT_elmozd{i}, 2)
                    jelenlegi_sejt = {1, j};
                    T_elm_ossz = [(ctT_elmozd_atlag(j)-ctMinT_elmozd{1,i}(1,h))*-1 ctMaxT_elmozd{1,i}(1,h)-ctT_elmozd_atlag(j)];
                    ct_kT_elmozd1 = [ct_kT_elmozd1 sum(T_elm_ossz)];
                    T_msd_ossz = [(ctT_msd_atlag(j)-ctMinT_msd{1,i}(1,h))*-1 ctMaxT_msd{1,i}(1,h)-ctT_msd_atlag(j)];
                    ct_kT_msd1 = [ct_kT_msd1 sum(T_msd_ossz)];
                    T_v_ossz = [(ctT_v_atlag(j)-ctMinT_v{1,i}(1,h))*-1 ctMaxT_v{1,i}(1,h)-ctT_v_atlag(j)];
                    ct_kT_v1 = [ct_kT_v1 sum(T_v_ossz)];
                    T_mu_ossz = [(ctT_mu_atlag(j)-ctMinT_mu{1,i}(1,h))*-1 ctMaxT_mu{1,i}(1,h)-ctT_mu_atlag(j)];
                    ct_kT_mu1 = [ct_kT_mu1 sum(T_mu_ossz)];
                    T_maxe_ossz = [(ctT_maxe_atlag(j)-ctMinT_maxe{1,i}(1,h))*-1 ctMaxT_maxe{1,i}(1,h)-ctT_maxe_atlag(j)];
                    ct_kT_maxe1 = [ct_kT_maxe1 sum(T_maxe_ossz)];
                    T_v_a_ossz = [(mean(ctlat_v_atlag_atlag{1,j}, 2, 'omitnan')-ctMinT_v_a{1,i}(1,h))*-1 ctMaxT_v_a{1,i}(1,h)-mean(ctlat_v_atlag_atlag{1,j}, 2, 'omitnan')];
                    ct_kT_v_a1 = [ct_kT_v_a1 sum(T_v_a_ossz)];
                    T_dr_ossz = [(mean(ctlat_ep_dr_atlag{1,j}, 2, 'omitnan')-ctMinT_dr{1,i}(1,h))*-1 ctMaxT_dr{1,i}(1,h)-mean(ctlat_ep_dr_atlag{1,j}, 2, 'omitnan')];
                    ct_kT_dr1 = [ct_kT_dr1 sum(T_dr_ossz)];
                    T_angleav_ossz = [(mean(ctlat_angleav_atlag{1,j}, 2, 'omitnan')-ctMinT_angleav{1,i}(1,h))*-1 ctMaxT_angleav{1,i}(1,h)-mean(ctlat_angleav_atlag{1,j}, 2, 'omitnan')];
                    ct_kT_angleav1 = [ct_kT_angleav1 sum(T_angleav_ossz)];
                    T_anglestd_ossz = [(mean(ctlat_anglestd_atlag{1,j}, 2, 'omitnan')-ctMinT_anglestd{1,i}(1,h))*-1 ctMaxT_anglestd{1,i}(1,h)-mean(ctlat_anglestd_atlag{1,j}, 2, 'omitnan')];
                    ct_kT_anglestd1 = [ct_kT_anglestd1 sum(T_anglestd_ossz)];
                    T_anglezc_ossz = [(mean(ctlat_anglezc_atlag{1,j}, 2, 'omitnan')-ctMinT_anglezc{1,i}(1,h))*-1 ctMaxT_anglezc{1,i}(1,h)-mean(ctlat_anglezc_atlag{1,j}, 2, 'omitnan')];
                    ct_kT_anglezc1 = [ct_kT_anglezc1 sum(T_anglezc_ossz)];
                end
            end
        end
        if ~isempty(ct_kT_elmozd1)
            ct_kT_elmozd{end+1} = ct_kT_elmozd1;
            ct_kT_msd{end+1} = ct_kT_msd1;
            ct_kT_v{end+1} = ct_kT_v1;
            ct_kT_v_a{end+1} = ct_kT_v_a1;
            ct_kT_mu{end+1} = ct_kT_mu1;
            ct_kT_maxe{end+1} = ct_kT_maxe1;
            ct_kT_dr{end+1} = ct_kT_dr1;
            ct_kT_angleav{end+1} = ct_kT_angleav1;
            ct_kT_anglestd{end+1} = ct_kT_anglestd1;
            ct_kT_anglezc{end+1} = ct_kT_anglezc1;
        end
    end
    
    thr_e = {};
    thr_msd = {};
    thr_v = {};
    thr_mu = {};
    thr_maxe = {};
    thr_v_a = {};
    thr_dr = {};
    thr_angleav = {};
    thr_anglestd = {};
    thr_anglezc = {};
    
    
    for i = 1:size(ct_kT_elmozd,2)
        SEM_e = std(ct_kT_elmozd{1,i})/sqrt(length(ct_kT_elmozd{1,i}));
        ts_e = tinv([0.025  0.975],length(ct_kT_elmozd{1,i})-1);
        thr1_e = (mean(ct_kT_elmozd{1,i}) + ts_e*SEM_e);
        thr_e{end+1} = thr1_e;
    
        SEM_msd = std(ct_kT_msd{1,i})/sqrt(length(ct_kT_msd{1,i}));
        ts_msd = tinv([0.025  0.975],length(ct_kT_msd{1,i})-1);
        thr1_msd = mean(ct_kT_msd{1,i}) + ts_msd*SEM_msd;
        thr_msd{end+1} = thr1_msd;
    
        SEM_v = std(ct_kT_v{1,i})/sqrt(length(ct_kT_v{1,i}));
        ts_v = tinv([0.025  0.975],length(ct_kT_v{1,i})-1);
        thr1_v = mean(ct_kT_v{1,i}) + ts_v*SEM_v;
        thr_v{end+1} = thr1_v;
    
        SEM_mu = std(ct_kT_mu{1,i})/sqrt(length(ct_kT_mu{1,i}));
        ts_mu = tinv([0.025  0.975],length(ct_kT_mu{1,i})-1);
        thr1_mu = mean(ct_kT_mu{1,i}) + ts_mu*SEM_mu;
        thr_mu{end+1} = thr1_mu;
    
        SEM_maxe = std(ct_kT_maxe{1,i})/sqrt(length(ct_kT_maxe{1,i}));
        ts_maxe = tinv([0.025  0.975],length(ct_kT_maxe{1,i})-1);
        thr1_maxe = mean(ct_kT_maxe{1,i}) + ts_maxe*SEM_maxe;
        thr_maxe{end+1} = thr1_maxe;
    
        SEM_v_a = std(ct_kT_v_a{1,i})/sqrt(length(ct_kT_v_a{1,i}));
        ts_v_a = tinv([0.025  0.975],length(ct_kT_v_a{1,i})-1);
        thr1_v_a = mean(ct_kT_v_a{1,i}) + ts_v_a*SEM_v_a;
        thr_v_a{end+1} = thr1_v_a;
    
        SEM_dr = std(ct_kT_dr{1,i})/sqrt(length(ct_kT_dr{1,i}));
        ts_dr = tinv([0.025  0.975],length(ct_kT_dr{1,i})-1);
        thr1_dr = mean(ct_kT_dr{1,i}) + ts_dr*SEM_dr;
        thr_dr{end+1} = thr1_dr;

        SEM_angleav = std(ct_kT_angleav{1,i})/sqrt(length(ct_kT_angleav{1,i}));
        ts_angleav = tinv([0.025  0.975],length(ct_kT_angleav{1,i})-1);
        thr1_angleav = mean(ct_kT_angleav{1,i}) + ts_angleav*SEM_angleav;
        thr_angleav{end+1} = thr1_angleav;
    
        SEM_anglestd = std(ct_kT_anglestd{1,i})/sqrt(length(ct_kT_anglestd{1,i}));
        ts_anglestd = tinv([0.025  0.975],length(ct_kT_anglestd{1,i})-1);
        thr1_anglestd = mean(ct_kT_anglestd{1,i}) + ts_anglestd*SEM_anglestd;
        thr_anglestd{end+1} = thr1_anglestd;
    
        SEM_anglezc = std(ct_kT_anglezc{1,i})/sqrt(length(ct_kT_anglezc{1,i}));
        ts_anglezc = tinv([0.025  0.975],length(ct_kT_anglezc{1,i})-1);
        thr1_anglezc = mean(ct_kT_anglezc{1,i}) + ts_anglezc*SEM_anglezc;
        thr_anglezc{end+1} = thr1_anglezc;
    end
    
    ct_kezsv2 = ct_kezsv1';
    
    %% Kezelesek puffer atlag osszehasonlitasa (kezeles AUC es puffer AUC)
    ctT_elmozd = {};
    ctT_msd = {};
    ctT_v = {};
    ctT_v_a = {};
    ctT_mu = {};
    ctT_maxe = {};
    ctT_dr = {};
    ctT_angleav = {};
    ctT_anglestd = {};
    ctT_anglezc = {};
    Tnev = {};
    ct_KontT = [];
    ct_KontT1 = [];
    
    for j = 1:size(ctlat_msd_atlag, 2)
        jelenlegi_sejt = ctlat_msd_atlag{1, j};
        ctT_elmozd1 = [];
        ctT_msd1 = [];
        ctT_v1 = [];
        ctT_v_a1 = [];
        ctT_mu1 = [];
        ctT_maxe1 = [];
        ctT_dr1 = [];
        ctT_angleav1 = [];
        ctT_anglestd1 = [];
        ctT_anglezc1 = [];
    
        KontT1 = [];
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
        MaxT_angleav = [];
        MinT_angleav = [];
        MaxT_anglestd = [];
        MinT_anglestd = [];
        MaxT_anglezc = [];
        MinT_anglezc = [];
    
        for g = 1:length(ct_kezsv1)
            if strcmp(ct_kont1{j}, ct_kezsv1{g})
                KontT1 = g;
            end
        end
        ct_KontT2 = find(ct_knum == KontT1);
        ct_KontT1 = [ct_KontT1 ct_KontT2];
        ct_KontT = [ct_KontT KontT1];
    
        for h = 1:size(jelenlegi_sejt,2)
    
            max_e = max(ctEl_atlag{KontT1},ctlat_elmozd_atlag{1,j}(:,h));
            max_e = max_e(~isnan(max_e));
            min_e = min(ctEl_atlag{KontT1},ctlat_elmozd_atlag{1,j}(:,h));
            min_e = min_e(~isnan(min_e));
            MaxT_elmozd = [MaxT_elmozd trapz(max_e)];
            MinT_elmozd = [MinT_elmozd trapz(min_e)];
        
            T_elm_ossz = [(ctT_elmozd_atlag(KontT1)-MinT_elmozd(h))*-1 MaxT_elmozd(h)-ctT_elmozd_atlag(KontT1)];
            ctT_elmozd1 = [ctT_elmozd1 sum(T_elm_ossz)];
        
            max_msd = max(ctMSD_atlag{KontT1},ctlat_msd_atlag{1,j}(:,h));
            max_msd = max_msd(~isnan(max_msd));
            min_msd = min(ctMSD_atlag{KontT1},ctlat_msd_atlag{1,j}(:,h));
            min_msd = min_msd(~isnan(min_msd));
            MaxT_msd = [MaxT_msd trapz(max_msd)];
            MinT_msd = [MinT_msd trapz(min_msd)];
        
            T_msd_ossz = [(ctT_msd_atlag(KontT1)-MinT_msd(h))*-1 MaxT_msd(h)-ctT_msd_atlag(KontT1)];
            ctT_msd1 = [ctT_msd1 sum(T_msd_ossz)];
        
            max_v = max(ctSeb_atlag{KontT1},ctlat_v_atlag{1,j}(:,h));
            max_v = max_v(~isnan(max_v));
            min_v = min(ctSeb_atlag{KontT1},ctlat_v_atlag{1,j}(:,h));
            min_v = min_v(~isnan(min_v));
            MaxT_v = [MaxT_v trapz(max_v)];
            MinT_v = [MinT_v trapz(min_v)];
        
            T_v_ossz = [(ctT_v_atlag(KontT1)-MinT_v(h))*-1 MaxT_v(h)-ctT_v_atlag(KontT1)];
            ctT_v1 = [ctT_v1 sum(T_v_ossz)];
        
            max_mu = max(ctMu_atlag{KontT1},ctlat_megtettut_eddig{1,j}(:,h));
            max_mu = max_mu(~isnan(max_mu));
            min_mu = min(ctMu_atlag{KontT1},ctlat_megtettut_eddig{1,j}(:,h));
            min_mu = min_mu(~isnan(min_mu));
            MaxT_mu = [MaxT_mu trapz(max_mu)];
            MinT_mu = [MinT_mu trapz(min_mu)];
        
            T_mu_ossz = [(ctT_mu_atlag(KontT1)-MinT_mu(h))*-1 MaxT_mu(h)-ctT_mu_atlag(KontT1)];
            ctT_mu1 = [ctT_mu1 sum(T_mu_ossz)];
        
            max_maxe = max(ctMaxe_atlag{KontT1},ctlat_maxelm_atlag{1,j}(:,h));
            max_maxe = max_maxe(~isnan(max_maxe));
            min_maxe = min(ctMaxe_atlag{KontT1},ctlat_maxelm_atlag{1,j}(:,h));
            min_maxe = min_maxe(~isnan(min_maxe));
            MaxT_maxe = [MaxT_maxe trapz(max_maxe)];
            MinT_maxe = [MinT_maxe trapz(min_maxe)];
        
            T_maxe_ossz = [(ctT_maxe_atlag(KontT1)-MinT_maxe(h))*-1 MaxT_maxe(h)-ctT_maxe_atlag(KontT1)];
            ctT_maxe1 = [ctT_maxe1 sum(T_maxe_ossz)];
    
            if ~isempty(ctlat_v_atlag_atlag{1,10})
                max_v_a = max(ctAseb_atlag{KontT1},ctlat_v_atlag_atlag{1,j}(:,h));
                min_v_a = min(ctAseb_atlag{KontT1},ctlat_v_atlag_atlag{1,j}(:,h));
                MaxT_v_a = [MaxT_v_a max_v_a];
                MinT_v_a = [MinT_v_a min_v_a];
            
                T_v_a_ossz = [(ctAseb_atlag{KontT1}-MinT_v_a(h))*-1 MaxT_v_a(h)-ctAseb_atlag{KontT1}];
                ctT_v_a1 = [ctT_v_a1 sum(T_v_a_ossz)];
        
                max_dr = max(ctDR_atlag{KontT1},ctlat_ep_dr_atlag{1,j}(:,h));
                min_dr = min(ctDR_atlag{KontT1},ctlat_ep_dr_atlag{1,j}(:,h));
                MaxT_dr = [MaxT_dr max_dr];
                MinT_dr = [MinT_dr min_dr];
            
                T_dr_ossz = [(ctDR_atlag{KontT1}-MinT_dr(h))*-1 MaxT_dr(h)-ctDR_atlag{KontT1}];
                ctT_dr1 = [ctT_dr1 sum(T_dr_ossz)];
    
                max_angleav = max(ctAngleav_atlag{KontT1},ctlat_angleav_atlag{1,j}(:,h));
                min_angleav = min(ctAngleav_atlag{KontT1},ctlat_angleav_atlag{1,j}(:,h));
                MaxT_angleav = [MaxT_angleav max_angleav];
                MinT_angleav = [MinT_angleav min_angleav];
            
                T_angleav_ossz = [(ctAngleav_atlag{KontT1}-MinT_angleav(h))*-1 MaxT_angleav(h)-ctAngleav_atlag{KontT1}];
                ctT_angleav1 = [ctT_angleav1 sum(T_angleav_ossz)];
    
                max_anglestd = max(ctAnglestd_atlag{KontT1},ctlat_anglestd_atlag{1,j}(:,h));
                min_anglestd = min(ctAnglestd_atlag{KontT1},ctlat_anglestd_atlag{1,j}(:,h));
                MaxT_anglestd = [MaxT_anglestd max_anglestd];
                MinT_anglestd = [MinT_anglestd min_anglestd];
            
                T_anglestd_ossz = [(ctAnglestd_atlag{KontT1}-MinT_anglestd(h))*-1 MaxT_anglestd(h)-ctAnglestd_atlag{KontT1}];
                ctT_anglestd1 = [ctT_anglestd1 sum(T_anglestd_ossz)];
    
                max_anglezc = max(ctAnglezc_atlag{KontT1},ctlat_anglezc_atlag{1,j}(:,h));
                min_anglezc = min(ctAnglezc_atlag{KontT1},ctlat_anglezc_atlag{1,j}(:,h));
                MaxT_anglezc = [MaxT_anglezc max_anglezc];
                MinT_anglezc = [MinT_anglezc min_anglezc];
            
                T_anglezc_ossz = [(ctAnglezc_atlag{KontT1}-MinT_anglezc(h))*-1 MaxT_anglezc(h)-ctAnglezc_atlag{KontT1}];
                ctT_anglezc1 = [ctT_anglezc1 sum(T_anglezc_ossz)];
            else
                T_v_a_ossz = [];
                ctT_v_a1 = [ctT_v_a1 T_v_a_ossz];
                T_dr_ossz = [];
                ctT_dr1 = [ctT_dr1 T_dr_ossz];
                T_angleav_ossz = [];
                ctT_angleav1 = [ctT_angleav1 T_angleav_ossz];
                T_anglestd_ossz = [];
                ctT_anglestd1 = [ctT_anglestd1 T_anglestd_ossz];
                T_anglezc_ossz = [];
                ctT_anglezc1 = [ctT_anglezc1 T_anglezc_ossz];
            end
    
            Tnev{end+1} = append(ct_kezsv1{j});
        end
        ctT_elmozd{end+1} = ctT_elmozd1;
        ctT_msd{end+1} = ctT_msd1;
        ctT_v{end+1} = ctT_v1;
        ctT_v_a{end+1} = ctT_v_a1;
        ctT_mu{end+1} = ctT_mu1;
        ctT_maxe{end+1} = ctT_maxe1;
        ctT_dr{end+1} = ctT_dr1;
        ctT_angleav{end+1} = ctT_angleav1;
        ctT_anglestd{end+1} = ctT_anglestd1;
        ctT_anglezc{end+1} = ctT_anglezc1;
    end
    
    ctT_a_elm_ossz = [];
    ctT_a_msd_ossz = [];
    ctT_a_maxe_ossz = [];
    ctT_a_v_ossz = [];
    ctT_a_av_ossz = [];
    ctT_a_dr_ossz = [];
    ctT_a_mu_ossz = [];
    ctT_a_angleav_ossz = [];
    ctT_a_anglestd_ossz = [];
    ctT_a_anglezc_ossz = [];
    ct_KontT1 = [];
    
    for j = 1:size(ctlat_msd_atlag, 2)
        jelenlegi_sejt = ctlat_msd_atlag{1, j};
    
        KontT1 = [];
    
        for g = 1:length(ct_kezsv1)
            if strcmp(ct_kont1{j}, ct_kezsv1{g})
                KontT1 = g;
            end
        end
        ct_KontT2 = find(ct_knum == KontT1);
        ct_KontT1 = [ct_KontT1 ct_KontT2];
    
        ctT_a_elm_ossz = [ctT_a_elm_ossz ctT_elmozd_atlag(j)/ctT_elmozd_atlag(KontT1)];
        ctT_a_msd_ossz = [ctT_a_msd_ossz ctT_msd_atlag(j)/ctT_msd_atlag(KontT1)];
        ctT_a_maxe_ossz = [ctT_a_maxe_ossz ctT_maxe_atlag(j)/ctT_maxe_atlag(KontT1)];
        ctT_a_v_ossz = [ctT_a_v_ossz ctT_v_atlag(j)/ctT_v_atlag(KontT1)];
        ctT_a_mu_ossz = [ctT_a_mu_ossz ctT_mu_atlag(j)/ctT_mu_atlag(KontT1)];
        if isempty(ctAseb_atlag{j})
            ctT_a_av_ossz = [ctT_a_av_ossz NaN];
            ctT_a_dr_ossz = [ctT_a_dr_ossz NaN];
            ctT_a_angleav_ossz = [ctT_a_angleav_ossz NaN];
            ctT_a_anglestd_ossz = [ctT_a_anglestd_ossz NaN];
            ctT_a_anglezc_ossz = [ctT_a_anglezc_ossz NaN];
        else
            ctT_a_av_ossz = [ctT_a_av_ossz ctAseb_atlag{j}/ctAseb_atlag{KontT1}];
            ctT_a_dr_ossz = [ctT_a_dr_ossz ctDR_atlag{j}/ctDR_atlag{KontT1}];
            ctT_a_angleav_ossz = [ctT_a_angleav_ossz ctAngleav_atlag{j}/ctAngleav_atlag{KontT1}];
            ctT_a_anglestd_ossz = [ctT_a_anglestd_ossz ctAnglestd_atlag{j}/ctAnglestd_atlag{KontT1}];
            ctT_a_anglezc_ossz = [ctT_a_anglezc_ossz ctAnglezc_atlag{j}/ctAnglezc_atlag{KontT1}];
        end
    end
    
    ctT_tf_elmozd = [];
    ctT_tf_maxe = [];
    ctT_tf_msd = [];
    ctT_tf_mu = [];
    ctT_tf_v = [];
    ctT_tf_v_a = [];
    ctT_tf_dr = [];
    ctT_tf_angleav = [];
    ctT_tf_anglestd = [];
    ctT_tf_anglezc = [];
    
    ctT_e_m = [];
    ctT_e_sd = [];
    ctT_maxe_m = [];
    ctT_maxe_sd = [];
    ctT_msd_m = [];
    ctT_msd_sd = [];
    ctT_mu_m = [];
    ctT_mu_sd = [];
    ctT_v_m = [];
    ctT_v_sd = [];
    ctT_av_m = [];
    ctT_av_sd = [];
    ctT_dr_m = [];
    ctT_dr_sd = [];
    ctT_angleav_m = [];
    ctT_angleav_sd = [];
    ctT_anglestd_m = [];
    ctT_anglestd_sd = [];
    ctT_anglezc_m = [];
    ctT_anglezc_sd = [];
    
    
    
    % Celltracker es kézi közötti különbség - normálás
    ct_k_msd = [];
    ct_k_e = [];
    ct_k_maxe = [];
    ct_k_mu = [];
    ct_k_v = [];
    ct_k_av = [];
    ct_k_dr = [];
    ct_k_angleav = [];
    ct_k_anglestd = [];
    ct_k_anglezc = [];
    ct_k_kezsv = {};
    for i = 1:size(ct_kezsv1, 2)
        for j = 1: size(k_kezsv1, 2)           
            if strcmp(ct_kezsv1{i}, k_kezsv1{j})
                ct_k_msd = [ct_k_msd ctT_msd_atlag(i)/kT_msd_atlag(j)];
                ct_k_e = [ct_k_e ctT_elmozd_atlag(i)/kT_elmozd_atlag(j)];
                ct_k_maxe = [ct_k_maxe ctT_maxe_atlag(i)/kT_maxe_atlag(j)];
                ct_k_mu = [ct_k_mu ctT_mu_atlag(i)/kT_mu_atlag(j)];
                ct_k_v = [ct_k_v ctT_v_atlag(i)/kT_v_atlag(j)];
                ct_k_av = [ct_k_av ctAseb_atlag{i}/kAseb_atlag{j}];
                ct_k_dr = [ct_k_dr ctDR_atlag{i}/kDR_atlag{j}];
                ct_k_angleav = [ct_k_angleav ctAngleav_atlag{i}/kAngleav_atlag{j}];
                ct_k_anglestd = [ct_k_anglestd ctAnglestd_atlag{i}/kAnglestd_atlag{j}];
                ct_k_anglezc = [ct_k_anglezc ctAnglezc_atlag{i}/kAnglezc_atlag{j}];
                ct_k_kezsv{end+1} = ct_kezsv1{i};
            end
        end
    end
    
    k_ltn = k_ltn';
    ct_ltn = ct_ltn';
    ct_k_kezsv = ct_k_kezsv';
    
    gepi_kezi_msd = mean(ct_k_msd);
    gepi_kezi_e = mean(ct_k_e);
    gepi_kezi_maxe = mean(ct_k_maxe);
    gepi_kezi_mu = mean(ct_k_mu);
    gepi_kezi_v = mean(ct_k_v);
    gepi_kezi_av = mean(ct_k_av);
    gepi_kezi_dr = mean(ct_k_dr);
    gepi_kezi_angleav = mean(ct_k_angleav);
    gepi_kezi_anglestd = mean(ct_k_anglestd);
    gepi_kezi_anglezc = mean(ct_k_anglezc);
    
    
    %% kiiratas
    Kul = [gepi_kezi_msd gepi_kezi_e gepi_kezi_maxe gepi_kezi_mu gepi_kezi_v gepi_kezi_av gepi_kezi_dr gepi_kezi_angleav gepi_kezi_anglezc];
    writematrix(Kul, 'gepi_kezi.xls', 'WriteMode', 'append');
    
    % Ez a rész az epsilon validálásához tartozik
    % epsilon = epsilon + 0.1;
    % fprintf('Epszilon = %d körnél tartunk\n', epsilon);
% end
% 
% catch ME
%     fprintf('Leallt a ciklus %d , epszilon %d -nél: %s\n', r, epsilon, ME.message);
% end

% Atlag = [kT_msd_m' kT_e_m' kT_maxe_m' kT_mu_m' kT_v_m' kT_av_m' kT_dr_m'];
% Szoras = [kT_msd_sd' kT_e_sd' kT_maxe_sd' kT_mu_sd' kT_v_sd' kT_av_sd' kT_dr_sd'];
% Threshold = [kT_tf_msd' kT_tf_elmozd' kT_tf_maxe' kT_tf_mu' kT_tf_v' kT_tf_v_a' kT_tf_dr'];
% Tort = [ctT_a_msd_ossz' ctT_a_elm_ossz' ctT_a_maxe_ossz' ctT_a_mu_ossz' ctT_a_v_ossz' ctT_a_av_ossz' ctT_a_dr_ossz'];
% Excelbe = [Threshold; Atlag; Szoras; Tort];
% writematrix(Excelbe, 'kAdatok.xls');
% 
% Atlag1 = [ctT_msd_m' ctT_e_m' ctT_maxe_m' ctT_mu_m' ctT_v_m' ctT_av_m' ctT_dr_m'];
% Szoras1 = [ctT_msd_sd' ctT_e_sd' ctT_maxe_sd' ctT_mu_sd' ctT_v_sd' ctT_av_sd' ctT_dr_sd'];
% Threshold1 = [ctT_tf_msd' ctT_tf_elmozd' ctT_tf_maxe' ctT_tf_mu' ctT_tf_v' ctT_tf_v_a' ctT_tf_dr'];
% Tort = [kT_a_msd_ossz' kT_a_elm_ossz' kT_a_maxe_ossz' kT_a_mu_ossz' kT_a_v_ossz' kT_a_av_ossz' kT_a_dr_ossz'];
% Excelbe1 = [Threshold1; Atlag1; Szoras1; Tort];
% writematrix(Excelbe1, 'ctAdatok.xls');

%% Összerakunk mindent 


for i = 1:size(ct_kezsvk, 2)
    for j = 1: size(k_kezsvk, 2)           
        if strcmp(ct_kezsvk{i}, k_kezsvk{j})
            k_kontroll = k_KontT(k_numk(j));
            ct_kontroll = ct_KontT(ct_numk(i));
            
            msd_m_i = {ctMSD_atlag{ct_numk(i)} ctMSD_atlag{ct_kontroll} kMSD_atlag{k_numk(j)} kMSD_atlag{k_kontroll}};
            msd_sz_i = {ctMSD_szoras{ct_numk(i)} ctMSD_szoras{ct_kontroll} kMSD_szoras{k_numk(j)} kMSD_szoras{k_kontroll}};
            leg_n = {append('ct ', ct_kezsv1{ct_numk(i)}) append('ct ', ct_kezsv1{ct_kontroll}) append('k ', k_kezsv1{k_numk(j)}) append('k ', k_kezsv1{k_kontroll})};
            t_i = {ct_t1{ct_numk(i)} ct_t1{ct_kontroll} k_t1{k_numk(j)} k_t1{k_kontroll}};
            e_m_i = {ctEl_atlag{ct_numk(i)} ctEl_atlag{ct_kontroll} kEl_atlag{k_numk(j)} kEl_atlag{k_kontroll}};
            e_sz_i = {ctEl_szoras{ct_numk(i)} ctEl_szoras{ct_kontroll} kEl_szoras{k_numk(j)} kEl_szoras{k_kontroll}};
            maxe_m_i = {ctMaxe_atlag{ct_numk(i)} ctMaxe_atlag{ct_kontroll} kMaxe_atlag{k_numk(j)} kMaxe_atlag{k_kontroll}};
            maxe_sz_i = {ctMaxe_szoras{ct_numk(i)} ctMaxe_szoras{ct_kontroll} kMaxe_szoras{k_numk(j)} kMaxe_szoras{k_kontroll}};
            mu_m_i = {ctMu_atlag{ct_numk(i)} ctMu_atlag{ct_kontroll} kMu_atlag{k_numk(j)} kMu_atlag{k_kontroll}};
            mu_sz_i = {ctMu_szoras{ct_numk(i)} ctMu_szoras{ct_kontroll} kMu_szoras{k_numk(j)} kMu_szoras{k_kontroll}};
            v_m_i = {ctSeb_atlag{ct_numk(i)} ctSeb_atlag{ct_kontroll} kSeb_atlag{k_numk(j)} kSeb_atlag{k_kontroll}};
            v_sz_i = {ctSeb_szoras{ct_numk(i)} ctSeb_szoras{ct_kontroll} kSeb_szoras{k_numk(j)} kSeb_szoras{k_kontroll}};
            av_m_i = {ctAseb_atlag{ct_numk(i)} ctAseb_atlag{ct_kontroll} kAseb_atlag{k_numk(j)} kAseb_atlag{k_kontroll}};
            av_sz_i = {ctAseb_szoras{ct_numk(i)} ctAseb_szoras{ct_kontroll} kAseb_szoras{k_numk(j)} kAseb_szoras{k_kontroll}};
            dr_m_i = {ctDR_atlag{ct_numk(i)} ctDR_atlag{ct_kontroll} kDR_atlag{k_numk(j)} kDR_atlag{k_kontroll}};
            dr_sz_i = {ctDR_szoras{ct_numk(i)} ctDR_szoras{ct_kontroll} kDR_szoras{k_numk(j)} kDR_szoras{k_kontroll}};
            angleav_m_i = {ctAngleav_atlag{ct_numk(i)} ctAngleav_atlag{ct_kontroll} kAngleav_atlag{k_numk(j)} kAngleav_atlag{k_kontroll}};
            angleav_sz_i = {ctAngleav_szoras{ct_numk(i)} ctAngleav_szoras{ct_kontroll} kAngleav_szoras{k_numk(j)} kAngleav_szoras{k_kontroll}};
            anglestd_m_i = {ctAnglestd_atlag{ct_numk(i)} ctAnglestd_atlag{ct_kontroll} kAnglestd_atlag{k_numk(j)} kAnglestd_atlag{k_kontroll}};
            anglestd_sz_i = {ctAnglestd_szoras{ct_numk(i)} ctAnglestd_szoras{ct_kontroll} kAnglestd_szoras{k_numk(j)} kAnglestd_szoras{k_kontroll}};
            anglezc_m_i = {ctAnglezc_atlag{ct_numk(i)} ctAnglezc_atlag{ct_kontroll} kAnglezc_atlag{k_numk(j)} kAnglezc_atlag{k_kontroll}};
            anglezc_sz_i = {ctAnglezc_szoras{ct_numk(i)} ctAnglezc_szoras{ct_kontroll} kAnglezc_szoras{k_numk(j)} kAnglezc_szoras{k_kontroll}};

            jelenlegi_sejtneve = ct_svk{i};
        end
    end
end

% % KD, JL, JR
% % ism1 = [2, 3, 8, 9];
% % ism2 = [4, 5, 10, 11];
% % ism3 = [1, 6, 7, 12, 13, 14, 15];
% % 
% % ism4 = [17, 18, 23, 24];
% % ism5 = [19, 20, 25, 26];
% % ism6 = [16, 21, 22, 27, 28, 29, 30];
% 
% % A2058-M1
% ism1 = [1, 2, 8, 9];
% ism2 = [3, 4, 10, 11];
% ism3 = [5, 6, 7, 12, 13, 14, 15];
% 
% ism4 = [16, 17, 23, 24];
% ism5 = [18, 19, 25, 26];
% ism6 = [20, 21, 22, 27, 28, 29, 30];
% 
% % WM
% % ism1 = [1, 2, 7, 8];
% % ism2 = [3, 4, 9, 10];
% % ism3 = [5, 6, 11, 12, 13, 14, 15];
% % 
% % ism4 = [16, 17, 22, 23];
% % ism5 = [18, 19, 24, 25];
% % ism6 = [20, 21, 26, 27, 28, 29, 30];
% ismetlodo = {ism1 ism2 ism3 ism4 ism5 ism6};
% 
% % end
% 
% %% NORM
% 
% kez_sejtv = {};
% kez_sejtv1 = {};
% for i = 1:size(kezsv3, 2)
%     kez_sejtv1 = {kezsv4{i} kezsv5{i}};
%     kez_sejtv{end+1} = kez_sejtv1;
% end
% 
% % Összeteszi kezelésenként
% % kez_masolat = kezsv5;
% % ism_kez = {};
% % for i = 1:size(kezsv5, 2)
% %     valtozo1 = [];
% %     for j = 1:size(kez_masolat, 2)
% %         if kez_masolat{j} ~= 0
% %             if strcmp(kezsv5{i}, kez_masolat{j})
% %                 valtozo1(end+1) = j;
% %                 kez_masolat{j} = 0;
% %             end
% %         end
% %     end
% %     if ~isempty(valtozo1)
% %         ism_kez{end+1} = valtozo1;
% %     end
% % end
% 
% val_normnev = {};
% 
% valt_msd = {};
% valt_mue = {};
% valt_maxe = {};
% valt_v = {};
% valt_e = {};
% valt_dr = {};
% valt_av = {};
% 
% valtoz_msd_t_a = {};
% valtoz_v_t_a = {};
% valtoz_av_t_a = {};
% valtoz_e_t_a = {};
% valtoz_maxe_t_a = {};
% valtoz_mue_t_a = {};
% valtoz_dr_t_a = {};
% 
% n_msd_a_o = {};
% n_mue_a_o = {};
% n_maxe_a_o = {};
% n_v_a_o = {};
% n_e_a_o = {};
% n_dr_a_o = {};
% n_av_a_o = {};
% 
% n_msd_t_o = {};
% n_v_t_o = {};
% n_av_t_o = {};
% n_e_t_o = {};
% n_maxe_t_o = {};
% n_mue_t_o = {};
% n_dr_t_o = {};
% 
% for i = 1:size(ismetlodo, 2)
%     jelenlegi_sejt = ismetlodo{1, i};
%     jelenlegi_sejtneve1 = kezsv4(jelenlegi_sejt(1));
%     jelenlegi_sejtneve = jelenlegi_sejtneve1{1};
%     legend_n1 = {};
%     fajloksz1 =[];
%     norm_v_ossz = {};
%     norm_v_atlag = {};
%     norm_v_szoras= {};
%     norm_msd_ossz = {};
%     norm_msd_atlag = {};
%     norm_msd_szoras = {};
%     norm_v_atl_ossz = {};
%     norm_v_atl_atlag = {};
%     norm_v_atl_szoras = {};
%     norm_ep_dr_ossz = {};
%     norm_ep_dr_atlag = {};
%     norm_ep_dr_szoras = {};
%     norm_maxelm_ossz = {};
%     norm_maxelm_atlag = {};
%     norm_maxelm_szoras = {};
%     norm_megtettut_eddig_ossz = {};
%     norm_megtettut_eddig_atlag = {};
%     norm_megtettut_eddig_szoras = {};
%     norm_elmozd_ossz = {};
%     norm_elmozd_atlag = {};
%     norm_elmozd_szoras = {}; 
% 
%     n_msd_t = {};
%     n_v_t = {};
%     n_av_t = {};
%     n_e_t = {};
%     n_maxe_t = {};
%     n_mue_t = {};
%     n_dr_t = {};
% 
% 
%     n_msd_a_a = {};
%     n_mue_a_a = {};
%     n_maxe_a_a = {};
%     n_v_a_a = {};
%     n_e_a_a = {};
% 
%     if ~isempty(ismetlodo{i})
%         cnt = {};
%         
%         % kontrollok szétválogatása
%         for h = 1:length(jelenlegi_sejt)
%             jelen = kez_sejtv{jelenlegi_sejt(h)};
%             for m = 1:length(kezsv5)
%                 if strcmp(kezsv5{m}, 'Puffer') && strcmp(kezsv4{m}, jelen{1}) 
%                     cnt{end+1} = m;
%                 end
%             end
%         end
%         
%         % Normalizáslás - Átlag számítás
%         if ~isempty(cnt)
%             for j = 1:length(jelenlegi_sejt)
%                     cnt1 = cnt{j};
%                     % Sebesseg normalizalas
%                     norm_v = lat_v_atlag{jelenlegi_sejt(j)}./Seb_atlag{cnt1};
%                     norm_v_ideig = [];
%                     for g = 1:size(norm_v,2)
%                         norm_v_ideig = [norm_v_ideig; norm_v(:,g)];
%                     end
%                     norm_v_ossz{end+1} = norm_v_ideig;
%                     norm_v_atlag{end+1} = mean(norm_v, 2, 'omitnan');
%                     norm_v_szoras{end+1} = std(norm_v, 0, 2, 'omitnan')/sqrt(size(norm_v,2));
%                 
%                 % MSD normalizalas
%                     norm_msd = lat_msd_atlag{jelenlegi_sejt(j)}./MSD_atlag{cnt1};
%                     norm_msd_ideig = [];
%                     for g = 1:size(norm_msd,2)
%                         norm_msd_ideig = [norm_msd_ideig; norm_msd(:,g)];
%                     end
%                     norm_msd_ossz{end+1} = norm_msd_ideig;
%                     norm_msd_atlag{end+1} = mean(norm_msd, 2, 'omitnan');
%                     norm_msd_szoras{end+1} = std(norm_msd, 0, 2, 'omitnan')/sqrt(size(norm_msd,2));
%     
%                 % Sebesseg atlag normalizalas
%                     norm_v_atl = lat_v_atlag_atlag{jelenlegi_sejt(j)}./Aseb_atlag{cnt1};
%                     norm_av_ideig = [];
%                     for g = 1:size(norm_v_atl,2)
%                         norm_av_ideig = [norm_av_ideig; norm_v_atl(:,g)];
%                     end
%                     norm_v_atl_ossz{end+1} = norm_av_ideig;
%                     norm_v_atl_atlag{end+1} = mean(norm_v_atl, 2, 'omitnan');
%                     norm_v_atl_szoras{end+1} = std(norm_v_atl, 0, 2, 'omitnan')/sqrt(size(norm_v_atl,2));
%     
%                 % Direkcionalitas normalizalas
%                     norm_ep_dr = lat_ep_dr_atlag{jelenlegi_sejt(j)}./DR_atlag{cnt1};
%                     norm_dr_ideig = [];
%                     for g = 1:size(norm_ep_dr,2)
%                         norm_dr_ideig = [norm_dr_ideig; norm_ep_dr(:,g)];
%                     end
%                     norm_ep_dr_ossz{end+1} = norm_dr_ideig;
%                     norm_ep_dr_atlag{end+1} = mean(norm_ep_dr, 2, 'omitnan');
%                     norm_ep_dr_szoras{end+1} = std(norm_ep_dr, 0, 2, 'omitnan')/sqrt(size(norm_ep_dr,2));
%     
%                 % Megtett ut normalizalas
%                     norm_maxelm = lat_maxelm_atlag{jelenlegi_sejt(j)}./Maxe_atlag{cnt1};
%                     norm_maxe_ideig = [];
%                     for g = 1:size(norm_maxelm,2)
%                         norm_maxe_ideig = [norm_maxe_ideig; norm_maxelm(:,g)];
%                     end
%                     norm_maxelm_ossz{end+1} = norm_maxe_ideig;
%                     norm_maxelm_atlag{end+1} = mean(norm_maxelm, 2, 'omitnan');
%                     norm_maxelm_szoras{end+1} = std(norm_maxelm, 0, 2, 'omitnan')/sqrt(size(norm_maxelm,2));
%     
%                 % Megtett ut eddig normalizalas
%                     norm_megtettut_eddig = lat_megtettut_eddig{jelenlegi_sejt(j)}./Mu_atlag{cnt1};
%                     norm_mue_ideig = [];
%                     for g = 1:size(norm_megtettut_eddig,2)
%                         norm_mue_ideig = [norm_mue_ideig; norm_megtettut_eddig(:,g)];
%                     end
%                     norm_megtettut_eddig_ossz{end+1} = norm_mue_ideig;
%                     norm_megtettut_eddig_atlag{end+1} = mean(norm_megtettut_eddig, 2,'omitnan');
%                     norm_megtettut_eddig_szoras{end+1} = std(norm_megtettut_eddig, 0, 2, 'omitnan')/sqrt(size(norm_megtettut_eddig,2));
%     
%                 % Elmozdulas normalizalas
%                     norm_elmozd = lat_elmozd_atlag{jelenlegi_sejt(j)}./El_atlag{cnt1};
%                     norm_e_ideig = [];
%                     for g = 1:size(norm_elmozd,2)
%                         norm_e_ideig = [norm_e_ideig; norm_elmozd(:,g)];
%                     end
%                     norm_elmozd_ossz{end+1} = norm_e_ideig;
%                     norm_elmozd_atlag{end+1} = mean(norm_elmozd, 2, 'omitnan');
%                     norm_elmozd_szoras{end+1} = std(norm_elmozd, 0, 2, 'omitnan')/sqrt(size(norm_elmozd,2));
% 
% 
%                 n_msd_sz = norm_msd_szoras{j};
%                 n_v_sz = norm_v_szoras{j};
%                 n_maxelm_sz = norm_maxelm_szoras{j};
%                 n_megtettut_eddig_sz = norm_megtettut_eddig_szoras{j};
%                 n_elm_sz = norm_elmozd_szoras{j};
% 
%                 n_msd_a = norm_msd_atlag{j};
%                 n_v_a = norm_v_atlag{j};
%                 n_maxelm_a = norm_maxelm_atlag{j};
%                 n_megtettut_eddig_a = norm_megtettut_eddig_atlag{j};
%                 n_elm_a = norm_elmozd_atlag{j};
% 
%                 for g = 1:2
%                     n_msd_sz(g) = 0;
%                     n_v_sz(g) = 0;
%                     n_maxelm_sz(g) = 0;
%                     n_megtettut_eddig_sz(g) = 0;
%                     n_elm_sz(g) = 0;
%                     n_msd_a(g) = NaN;
%                     n_v_a(g) = NaN;
%                     n_maxelm_a(g) = NaN;
%                     n_megtettut_eddig_a(g) = NaN;
%                     n_elm_a(g) = NaN;
%                 end
% 
%                 norm_msd_szoras{j} = n_msd_sz;
%                 norm_v_szoras{j} = n_v_sz;
%                 norm_maxelm_szoras{j} = n_maxelm_sz;
%                 norm_megtettut_eddig_szoras{j} = n_megtettut_eddig_sz;
%                 norm_elmozd_szoras{j} = n_elm_sz;
% 
%                 norm_msd_atlag{j} = n_msd_a;
%                 n_msd_a_a{end+1} = mean(norm_msd_atlag{j}, 1, 'omitnan');
% 
%                 norm_v_atlag{j} = n_v_a;
%                 n_v_a_a{end+1} = mean(norm_v_atlag{j}, 1, 'omitnan');
% 
%                 norm_maxelm_atlag{j} = n_maxelm_a;
%                 n_maxe_a_a{end+1} = mean(norm_maxelm_atlag{j}, 1, 'omitnan');
% 
%                 norm_megtettut_eddig_atlag{j} = n_megtettut_eddig_a;
%                 n_mue_a_a{end+1} = mean(norm_megtettut_eddig_atlag{j}, 1, 'omitnan');
% 
%                 norm_elmozd_atlag{j} = n_elm_a;
%                 n_e_a_a{end+1} = mean(norm_elmozd_atlag{j}, 1, 'omitnan');
% 
%                 % t proba h = ttest(x,m) h0 => mean is m; 
%                 % 5% significance level
%                 n_msd_t{end+1} = ttest(norm_msd_ossz{j}, 1);
%                 n_v_t{end+1} = ttest(norm_v_ossz{j}, 1);
%                 n_av_t{end+1} = ttest(norm_v_atl_ossz{j}, 1);
%                 n_e_t{end+1} = ttest(norm_elmozd_ossz{j}, 1);
%                 n_maxe_t{end+1} = ttest(norm_maxelm_ossz{j}, 1);
%                 n_mue_t{end+1} = ttest(norm_megtettut_eddig_ossz{j}, 1);
%                 n_dr_t{end+1} = ttest(norm_ep_dr_ossz{j}, 1);
%                 
%                 valtoz_msd_t_a{end+1} = mean(norm_msd_ossz{j}, 1, 'omitnan');
%                 valtoz_v_t_a{end+1} = mean(norm_v_ossz{j}, 1, 'omitnan');
%                 valtoz_av_t_a{end+1} = mean(norm_v_atl_ossz{j}, 1, 'omitnan');
%                 valtoz_e_t_a{end+1} = mean(norm_elmozd_ossz{j}, 1, 'omitnan');
%                 valtoz_maxe_t_a{end+1} = mean(norm_maxelm_ossz{j}, 1, 'omitnan');
%                 valtoz_mue_t_a{end+1} = mean(norm_megtettut_eddig_ossz{j}, 1, 'omitnan');
%                 valtoz_dr_t_a{end+1} = mean(norm_ep_dr_ossz{j}, 1, 'omitnan');
%                 
% 
%                 if n_msd_t{j} == 0
%                     valt_msd{end+1} = 0;
%                 elseif n_msd_t{j} ~= 0 && n_msd_a_a{j} < 1
%                     valt_msd{end+1} = -1;
%                 elseif n_msd_t{j} ~= 0 && n_msd_a_a{j} > 1
%                     valt_msd{end+1} = 1;                    
%                 end
% 
%                 if n_mue_t{j} == 0
%                     valt_mue{end+1} = 0;
%                 elseif n_mue_t{j} ~= 0 && n_mue_a_a{j} < 1
%                     valt_mue{end+1} =-1;
%                 elseif n_mue_t{j} ~= 0 && n_mue_a_a{j} > 1
%                     valt_mue{end+1} = 1;                    
%                 end
% 
%                 if n_maxe_t{j} == 0
%                     valt_maxe{end+1} = 0;
%                 elseif n_maxe_t{j} ~= 0 && n_maxe_a_a{j} < 1
%                     valt_maxe{end+1} =-1;
%                 elseif n_maxe_t{j} ~= 0 && n_maxe_a_a{j} > 1
%                     valt_maxe{end+1} = 1;                    
%                 end
% 
%                 if n_v_t{j} == 0
%                     valt_v{end+1} = 0;
%                 elseif n_v_t{j} ~= 0 && n_v_a_a{j} < 1
%                     valt_v{end+1} =-1;
%                 elseif n_v_t{j} ~= 0 && n_v_a_a{j} > 1
%                     valt_v{end+1} = 1;                    
%                 end
% 
%                 if n_e_t{j} == 0
%                     valt_e{end+1} = 0;
%                 elseif n_e_t{j} ~= 0 && n_e_a_a{j} < 1
%                     valt_e{end+1} =-1;
%                 elseif n_e_t{j} ~= 0 && n_e_a_a{j} > 1
%                     valt_e{end+1} = 1;                    
%                 end
% 
%                 if n_av_t{j} == 0
%                     valt_av{end+1} = 0;
%                 elseif n_av_t{j} ~= 0 && norm_v_atl_atlag{j} < 1
%                     valt_av{end+1} =-1;
%                 elseif n_av_t{j} ~= 0 && norm_v_atl_atlag{j} > 1
%                     valt_av{end+1} = 1;                    
%                 end
% 
%                 if n_dr_t{j} == 0
%                     valt_dr{end+1} = 0;
%                 elseif n_dr_t{j} ~= 0 && norm_ep_dr_atlag{j} < 1
%                     valt_dr{end+1} =-1;
%                 elseif n_dr_t{j} ~= 0 && norm_ep_dr_atlag{j} > 1
%                     valt_dr{end+1} = 1;                    
%                 end
% 
% 
%             end
% 
% 
%         
%         % Direkcionalitas plot
%             figure(1)
%             hold on
%             for j = 1:length(jelenlegi_sejt)
%                 fajloksz2 = num2str(size(lat_msd_atlag{jelenlegi_sejt(j)},2));
%                 legend_n1{end+1} = kezsv3{jelenlegi_sejt(j)};                
%     
%                 e = norm_ep_dr_atlag{j};
%                 x = norm_ep_dr_szoras{j};
%     
%                 title(sprintf('DR %s sejtvonalra', jelenlegi_sejtneve));
%     
%                 h = bar(j, e, 'FaceColor', cl_colors{j});
%     
%                 % Szépségek és kiegészítés
%                 legend(legend_n1, 'Interpreter', 'none', 'Location','southoutside');
%                 grid on;
%                 xlabel('Sejtvonal');
%                 ylabel('directionality');
%                 xticks([]);
%     
%                 pause(0.00001);
%                 frame_h = get(handle(gcf),'JavaFrame');
%                 set(frame_h,'Maximized',1);
%             end
%             hold on
%             for j = 1:length(jelenlegi_sejt)
%                 e = norm_ep_dr_atlag{j};
%                 x = norm_ep_dr_szoras{j};
%                 errorbar(j,e,x, '.k');
%             end
%             hold on
%             yline(1,'-');
% 
%         % Elmozdulas plot
%             figure(2)
%             hold on
%             for j = 1:length(jelenlegi_sejt)
%     
%                 e = norm_elmozd_atlag{j};
%                 s = norm_elmozd_szoras{j};
%     
%                 n = size(e, 1);
%                 perc = 0:t:n*t-1;
%                 ido  = (perc/60);  % ora - h 
%     
%                 % A konkrét adatok kirajzolása
%                 title(sprintf('Elmozdulás %s sejtvonalra', jelenlegi_sejtneve));
%     
%                 h = errorbar(ido, e, s, '-*', 'Color', cl_colors{j});
%     
%                 % Szépségek és kiegészítés
%                 legend(legend_n1, 'Interpreter', 'none', 'Location','southoutside');
%                 grid on;
%                 xlabel('Idő [h]');
%                 ylabel('Elmozdulás [um/s]');
%                 xticks(0:2:24);
%                 xlim([0 24]);
% %                 ylim([0.2 4]);
%     
%                 pause(0.00001);
%                 frame_h = get(handle(gcf),'JavaFrame');
%                 set(frame_h,'Maximized',1);
%             end
%             hold on
%             yline(1,'-');
%     
%         % Sebesseg plot
%             figure(3)
%             hold on
%             for j = 1:length(jelenlegi_sejt)
%     
%                 e = norm_v_atlag{j};
%                 s = norm_v_szoras{j};
%     
%                 n = size(e, 1);
%                 perc = 0:t:n*t-1;
%                 ido  = (perc/60);  % ora - h 
%     
%                 % A konkrét adatok kirajzolása
%                 title(sprintf('Sebesség %s sejtvonalra', jelenlegi_sejtneve));
%     
%                 h = errorbar(ido, e, s, '-*', 'Color', cl_colors{j});
%     
%                 % Szépségek és kiegészítés
%                 legend(legend_n1, 'Interpreter', 'none', 'Location','southoutside');
%                 grid on;
%                 xlabel('Idő [h]');
%                 ylabel('Sebesség [um/s]');
%                 xticks(0:2:24);
%                 xlim([0 24]);
% %                 ylim([0 16]);
%     
%                 pause(0.00001);
%                 frame_h = get(handle(gcf),'JavaFrame');
%                 set(frame_h,'Maximized',1);
%             end
%             hold on
%             yline(1,'-');
%     
%         % Megtett ut eddig plot
%             figure(4)
%             hold on
%             for j = 1:length(jelenlegi_sejt)
%     
%                 e = norm_megtettut_eddig_atlag{j};
%                 s = norm_megtettut_eddig_szoras{j};
%     
%                 n = size(e, 1);
%                 perc = 0:t:n*t-1;
%                 ido  = (perc/60);  % ora - h 
%     
%                 % A konkrét adatok kirajzolása
%                 title(sprintf('Megtett út eddig %s sejtvonalra', jelenlegi_sejtneve));
%     
%                 h = errorbar(ido, e, s, '-*', 'Color', cl_colors{j});
%     
%                 % Szépségek és kiegészítés
%                 legend(legend_n1, 'Interpreter', 'none', 'Location','southoutside');
%                 grid on;
%                 xlabel('Idő [h]');
%                 ylabel('Megtett út [um]');
%                 xticks(0:2:24);
%                 xlim([0 24]);
% %                 ylim([0 2.3]);
%     
%                 pause(0.00001);
%                 frame_h = get(handle(gcf),'JavaFrame');
%                 set(frame_h,'Maximized',1);
%             end
%             hold on
%             yline(1,'-');
%     
%         % Sebesseg atlag plot
%             figure(5)
%             hold on
%             for j = 1:length(jelenlegi_sejt)
%     
%                 e = norm_v_atl_atlag{j};
%                 x = norm_v_atl_szoras{j};
%     
%                 % A konkrét adatok kirajzolása
%                 title(sprintf('Sebesség átlag %s sejtvonalra', jelenlegi_sejtneve));
%     
%                 h = bar(j, e, 'FaceColor', cl_colors{j});
%      
%                 % Szépségek és kiegészítés
%                 legend(legend_n1, 'Interpreter', 'none', 'Location','southoutside');
%                 grid on;
%                 xlabel('Sejtvonal');
%                 ylabel('Átlag sebesség [um/s]');
%                 xticks([]);
%     
%                 pause(0.00001);
%                 frame_h = get(handle(gcf),'JavaFrame');
%                 set(frame_h,'Maximized',1);
%     
%             end
%             hold on
%             for j = 1:length(jelenlegi_sejt)
%                 e = norm_v_atl_atlag{j};
%                 x = norm_v_atl_szoras{j};
%                 errorbar(j,e,x, '.k');
%             end
%             hold on
%             yline(1,'-');
%      
%         % Megtett ut plot
%             figure(6)
%             hold on
%             for j = 1:length(jelenlegi_sejt)
%     
%                 e = norm_maxelm_atlag{j};
%                 s = norm_maxelm_szoras{j};
%     
%                 n = size(e, 1);
%                 perc = 0:t:n*t-1;
%                 ido  = (perc/60);  % ora - h 
%     
%                 % A konkrét adatok kirajzolása
%                 title(sprintf('Max elmozdulas %s sejtvonalra', jelenlegi_sejtneve));
%     
%                 h = errorbar(ido, e, s, '-*', 'Color', cl_colors{j});
%     
%                 % Szépségek és kiegészítés
%     
%                 legend(legend_n1, 'Interpreter', 'none', 'Location','southoutside');
%                 grid on;
%                 xlabel('Idő [h]');
%                 ylabel('Időegység alatti max elmozdulas[um]');
%                 xticks(0:2:24);
%                 xlim([0 24]);
% %                 ylim([0 16]);
% 
%     
%                 pause(0.00001);
%                 frame_h = get(handle(gcf),'JavaFrame');
%                 set(frame_h,'Maximized',1);
%             end
%             hold on
%             yline(1,'-');
%     
%         % MSD plot
%             figure(7)
%             hold on
%             for j = 1:length(jelenlegi_sejt)
%     
%                 e = norm_msd_atlag{j};
%                 s = norm_msd_szoras{j};
%     
%                 n = size(e, 1);
%                 perc = 0:t:n*t-1;
%                 ido  = (perc/60);  % ora - h 
%     
%                 % A konkrét adatok kirajzolása
%                 title(sprintf('MSD %s sejtvonalra', jelenlegi_sejtneve));
%     
%                 h = errorbar(ido, e, s, '-*', 'Color', cl_colors{j});
%     
%                 % Szépségek és kiegészítés
%                 legend(legend_n1, 'Interpreter', 'none', 'Location','southoutside');
%                 grid on;
%                 xlabel('Idő [h]');
%                 ylabel('sqrt(MSD) [um]');
%                 xticks(0:2:24);
%                 xlim([0 24]);
%     
%                 pause(0.00001);
%                 frame_h = get(handle(gcf),'JavaFrame');
%                 set(frame_h,'Maximized',1);
%             end
%             hold on
%             yline(1,'-');
% 
%         end
% 
%     end
%     val_normnev = [val_normnev legend_n1];
% 
%     n_msd_a_o{end+1} = n_msd_a_a;
%     n_e_a_o{end+1} = n_e_a_a;
%     n_v_a_o{end+1} = n_v_a_a;
%     n_maxe_a_o{end+1} = n_maxe_a_a;
%     n_mue_a_o{end+1} = n_mue_a_o;
%     n_av_a_o{end+1} = norm_v_atl_atlag;
%     n_dr_a_o{end+1} = norm_ep_dr_atlag;
% 
%     n_msd_t_o{end+1} = cell2mat(n_msd_t);
%     n_v_t_o{end+1} = cell2mat(n_v_t);
%     n_av_t_o{end+1} = cell2mat(n_av_t);
%     n_e_t_o{end+1} = cell2mat(n_e_t);
%     n_maxe_t_o{end+1} = cell2mat(n_maxe_t);
%     n_mue_t_o{end+1} = cell2mat(n_mue_t);
%     n_dr_t_o{end+1} = cell2mat(n_dr_t);
% 
% 
% 
%     clc; clf; close all;    
% end
% 
% n_msd_t_o = cell2mat(n_msd_t_o);
% n_v_t_o = cell2mat(n_v_t_o);
% n_av_t_o = cell2mat(n_av_t_o);
% n_e_t_o = cell2mat(n_e_t_o);
% n_maxe_t_o = cell2mat(n_maxe_t_o);
% n_mue_t_o = cell2mat(n_mue_t_o);
% n_dr_t_o = cell2mat(n_dr_t_o);