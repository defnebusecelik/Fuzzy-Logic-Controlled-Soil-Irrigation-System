% irrigation_control_trapmf_expanded.m: Mamdani Bulanýk Sulama Kontrol Scripti (Trapmf) - Tam Kural Tabaný
clear; close all; clc;

% 1. FIS Oluþturma
fis = newfis('IrrigationControl','mamdani');

% 2. Girdi Deðiþkenleri ve Yamuk (trapmf) Üyelik Fonksiyonlarý
% Toprak Nem
fis = addInput(fis,[0 100],'Name','ToprakNem');
fis = addMF(fis,'ToprakNem','trapmf',[0   0   0   20],'Name','Kuru');
fis = addMF(fis,'ToprakNem','trapmf',[15  25  35  45],'Name','AzNemli');
fis = addMF(fis,'ToprakNem','trapmf',[45 50 60 65],'Name','OrtaNemli');
fis = addMF(fis,'ToprakNem','trapmf',[65 100 100 100],'Name','CokNemli');

% Sicaklik
fis = addInput(fis,[0 50],'Name','Sicaklik');
fis = addMF(fis,'Sicaklik','trapmf',[0   0   0   10],'Name','Soguk');
fis = addMF(fis,'Sicaklik','trapmf',[8   13  23  28],'Name','Ilik');
fis = addMF(fis,'Sicaklik','trapmf',[25  30  40  45],'Name','Sicak');
fis = addMF(fis,'Sicaklik','trapmf',[40  50  50  50],'Name','CokSicak');

% Yagis
fis = addInput(fis,[0 20],'Name','Yagis');
fis = addMF(fis,'Yagis','trapmf',[0    0    0    1],'Name','Yok');
fis = addMF(fis,'Yagis','trapmf',[0.5  1.75 4.5  6],'Name','AzYagisli');
fis = addMF(fis,'Yagis','trapmf',[5    8.75 11.25 15],'Name','OrtaYagisli');
fis = addMF(fis,'Yagis','trapmf',[12   20   20   20],'Name','CokYagisli');

% Urun Su Ihtiyaci
fis = addInput(fis,[0 10],'Name','UrunSuIhtiyaci');
fis = addMF(fis,'UrunSuIhtiyaci','trapmf',[0   0    0    2],'Name','Dusuk');
fis = addMF(fis,'UrunSuIhtiyaci','trapmf',[1.5 2.5  4.25 5],'Name','OrtaDusuk');
fis = addMF(fis,'UrunSuIhtiyaci','trapmf',[4.5 5.5  7.25 8],'Name','OrtaYuksek');
fis = addMF(fis,'UrunSuIhtiyaci','trapmf',[7   10   10   10],'Name','Yuksek');

% Bagil Nem
fis = addInput(fis,[0 100],'Name','BagilNem');
fis = addMF(fis,'BagilNem','trapmf',[0   0   0   20],'Name','Kurak');
fis = addMF(fis,'BagilNem','trapmf',[15  25  35  45],'Name','AzNemli');
fis = addMF(fis,'BagilNem','trapmf',[40  50  70  80],'Name','Nemli');
fis = addMF(fis,'BagilNem','trapmf',[75 100 100 100],'Name','CokNemli');

% 3. Çýktý Deðiþkeni: Sulama Süresi (0-60 dk)
fis = addOutput(fis,[0 60],'Name','SulamaSuresi');
fis = addMF(fis,'SulamaSuresi','trapmf',[0   0   0   15],'Name','Kisa');
fis = addMF(fis,'SulamaSuresi','trapmf',[5  15  15  30],'Name','Orta');
fis = addMF(fis,'SulamaSuresi','trapmf',[15  25  25  60],'Name','Uzun');

% 4. Kural Tabaný Oluþturma (Tam Kombinasyon: 4^5 = 1024 kural)
ruleList = [];
for tn = 1:4
    for sk = 1:4
        for yg = 1:4
            for ui = 1:4
                for bn = 1:4
                    memAvg = mean([tn, sk, yg, ui, bn]);
                    % cs: 1(Kýsa), 2(Orta), 3(Uzun)
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

% 7. Sonuçlarý Karþýlaþtýr ve Yazdýr (8 dk Tolerans)
tol    = 10;                          % 8 dakika tolerans
derrors = abs(actual - expected);
isMatch= derrors <= tol;

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

% 8. Hata Daðýlýmýný Görselleþtirme
figure;
bar(derrors);
hold on;
yline(tol, 'r--', sprintf('Tolerans (%d dk)', tol));
xlabel('Test Numarasi');
ylabel('|Actual - Expected| (dk)');
title('Sulama Suresi Hata Dagilimi');
legend('Hata','Tolerans','Location','northoutside');