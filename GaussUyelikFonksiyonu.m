% irrigation_control_gaussmf.m: Mamdani Bulanýk Sulama Kontrol Scripti (Gaussmf) - Tam Kural Tabaný
clear; close all; clc;

% 1. FIS Oluþturma
fis = newfis('IrrigationControl','mamdani');

% 2. Girdi Deðiþkenleri ve Gauss Üyelik Fonksiyonlarý
% Toprak Nem (0–100)
fis = addInput(fis,[0 100],'Name','ToprakNem');
fis = addMF(fis,'ToprakNem','gaussmf',[10   0   ],'Name','Kuru');         % sigma=10, mean=0
fis = addMF(fis,'ToprakNem','gaussmf',[10  25   ],'Name','AzNemli');     % sigma=10, mean=25
fis = addMF(fis,'ToprakNem','gaussmf',[15  55   ],'Name','OrtaNemli');   % sigma=15, mean=55
fis = addMF(fis,'ToprakNem','gaussmf',[14.5 100 ],'Name','CokNemli');    % sigma=17.5, mean=100

% Sýcaklýk (0–50)
fis = addInput(fis,[0 50],'Name','Sicaklik');
fis = addMF(fis,'Sicaklik','gaussmf',[5    0   ],'Name','Soguk');        % sigma=5, mean=0
fis = addMF(fis,'Sicaklik','gaussmf',[8.526   18  ],'Name','Ilik');         % sigma=10, mean=18
fis = addMF(fis,'Sicaklik','gaussmf',[7.5   35  ],'Name','Sicak');        % sigma=10, mean=35
fis = addMF(fis,'Sicaklik','gaussmf',[5    50  ],'Name','CokSicak');     % sigma=5, mean=50

% Yaðýþ (0–20)
fis = addInput(fis,[0 20],'Name','Yagis');
fis = addMF(fis,'Yagis','gaussmf',[0.5  0   ],'Name','Yok');            % sigma=0.5, mean=0
fis = addMF(fis,'Yagis','gaussmf',[2.75  3   ],'Name','AzYagisli');     % sigma=2.75, mean=3
fis = addMF(fis,'Yagis','gaussmf',[2.652     10  ],'Name','OrtaYagisli');   % sigma=2.652, mean=10
fis = addMF(fis,'Yagis','gaussmf',[4     20  ],'Name','CokYagisli');   % sigma=4, mean=20

% Ürün Su Ýhtiyacý (0–10)
fis = addInput(fis,[0 10],'Name','UrunSuIhtiyaci');
fis = addMF(fis,'UrunSuIhtiyaci','gaussmf',[1    0   ],'Name','Dusuk');         % sigma=1, mean=0
fis = addMF(fis,'UrunSuIhtiyaci','gaussmf',[1.333 3.5 ],'Name','BirazDusuk');    % sigma=1.75, mean=3.5
fis = addMF(fis,'UrunSuIhtiyaci','gaussmf',[1.346 6.5 ],'Name','BirazYuksek');  % sigma=1.75, mean=6.5
fis = addMF(fis,'UrunSuIhtiyaci','gaussmf',[1.5  10  ],'Name','Yuksek');        % sigma=1.5, mean=10

% Baðýl Nem (0–100)
fis = addInput(fis,[0 100],'Name','BagilNem');
fis = addMF(fis,'BagilNem','gaussmf',[10   0   ],'Name','Kurak');        % sigma=10, mean=0
fis = addMF(fis,'BagilNem','gaussmf',[15   30  ],'Name','AzNemli');     % sigma=15, mean=30
fis = addMF(fis,'BagilNem','gaussmf',[20   60  ],'Name','Nemli');       % sigma=20, mean=60
fis = addMF(fis,'BagilNem','gaussmf',[12.5 100 ],'Name','CokNemli');    % sigma=12.5, mean=100

% 3. Çýktý Deðiþkeni: Sulama Süresi (0–60 dk) – Gauss Üyelik Fonksiyonlarý
fis = addOutput(fis,[0 60],'Name','SulamaSuresi');
fis = addMF(fis,'SulamaSuresi','gaussmf',[7.5  0  ],'Name','Kisa');      % sigma=7.5, mean=0
fis = addMF(fis,'SulamaSuresi','gaussmf',[20   30 ],'Name','Orta');      % sigma=20, mean=30
fis = addMF(fis,'SulamaSuresi','gaussmf',[10   60 ],'Name','Uzun');     % sigma=10, mean=60

% 4. Kural Tabaný Oluþturma (4^5 = 1024 kural, orijinal yöntemle)
ruleList = [];
for tn = 1:4
    for sk = 1:4
        for yg = 1:4
            for ui = 1:4
                for bn = 1:4
                    memAvg = mean([tn, sk, yg, ui, bn]);
                    cs = 1 + (memAvg >= 2) + (memAvg >= 3);
                    ruleList(end+1,:) = [tn, sk, yg, ui, bn, cs, 1, 1];
                end
            end
        end
    end
end
fis = addrule(fis, ruleList);

% 5. Test Verisini Oku
T = readtable('C:\Users\hp\Desktop\bulanýk proje\testdatanew.csv');
tests    = [T.ToprakNem, T.Sicaklik, T.Yagis, T.UrunSuIhtiyaci, T.BagilNem];
expected = T.Expected;
numTests = size(tests,1);

% 6. Otomatik Test Döngüsü
actual = zeros(numTests,1);
for i = 1:numTests
    actual(i) = evalfis(tests(i,:), fis);
end

% 7. Sonuçlarý Karþýlaþtýr ve Yazdýr (10 dk Tolerans)
tol     = 10;
derrors = abs(actual - expected);
isMatch = derrors <= tol;

fprintf('Toplam test sayisi: %d\n', numTests);
fprintf('Uyumlu (<= %d dk fark): %d\n', tol, sum(isMatch));
fprintf('Uyumsuz (> %d dk fark): %d\n', tol, numTests - sum(isMatch));

misIdx = find(~isMatch);
if ~isempty(misIdx)
    fprintf('\nUyumsuz test numaralari ve hatalar (dk):\n');
    for j = 1:numel(misIdx)
        idx = misIdx(j);
        fprintf('  Test %2d: Expected=%.2f, Actual=%.2f, Hata=%.2f\n', ...
                idx, expected(idx), actual(idx), derrors(idx));
    end
end

% 8. Hata Daðýlýmýnýn Görselleþtirilmesi
figure;
bar(derrors);
hold on;
yline(tol, 'r--', sprintf('Tolerans (%d dk)', tol));
xlabel('Test Numarasi');
ylabel('|Actual - Expected| (dk)');
title('Sulama Suresi Hata Dagilimi (Gauss Üyelik)');
legend('Hata','Tolerans','Location','northoutside');
