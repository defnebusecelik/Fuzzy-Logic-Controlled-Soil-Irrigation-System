% irrigation_control_trimf_expanded.m: Mamdani Bulanýk Sulama Kontrol Scripti (Trimf) - Tam Kural Tabaný
clear; close all; clc;

% 1. FIS Oluþturma
fis = newfis('IrrigationControl','mamdani');

% 2. Girdi Deðiþkenleri ve Üçgen (trimf) Üyelik Fonksiyonlarý
% Toprak Nem
fis = addInput(fis,[0 100],'Name','ToprakNem');
fis = addMF(fis,'ToprakNem','trimf',[0   0   20],'Name','Kuru');
fis = addMF(fis,'ToprakNem','trimf',[15 25 35],'Name','AzNemli');
fis = addMF(fis,'ToprakNem','trimf',[40 55 70],'Name','OrtaNemli');
fis = addMF(fis,'ToprakNem','trimf',[65 100 100],'Name','CokNemli');

% Sicaklik
fis = addInput(fis,[0 50],'Name','Sicaklik');
fis = addMF(fis,'Sicaklik','trimf',[0   0   10],'Name','Soguk');
fis = addMF(fis,'Sicaklik','trimf',[8   18  28],'Name','Ilik');
fis = addMF(fis,'Sicaklik','trimf',[25  35  45],'Name','Sicak');
fis = addMF(fis,'Sicaklik','trimf',[40  50  50],'Name','CokSicak');

% Yagis
fis = addInput(fis,[0 20],'Name','Yagis');
fis = addMF(fis,'Yagis','trimf',[0    0    1],'Name','Yok');
fis = addMF(fis,'Yagis','trimf',[0.5  3    6],'Name','AzYagisli');
fis = addMF(fis,'Yagis','trimf',[5    10   15],'Name','OrtaYagisli');
fis = addMF(fis,'Yagis','trimf',[12   20   20],'Name','CokYagisli');

% Urun Su Ihtiyaci
fis = addInput(fis,[0 10],'Name','UrunSuIhtiyaci');
fis = addMF(fis,'UrunSuIhtiyaci','trimf',[0   0    2],'Name','Dusuk');
fis = addMF(fis,'UrunSuIhtiyaci','trimf',[1.5 3.5  5],'Name','OrtaDusuk');
fis = addMF(fis,'UrunSuIhtiyaci','trimf',[4.5 6.5  8],'Name','OrtaYuksek');
fis = addMF(fis,'UrunSuIhtiyaci','trimf',[7   10   10],'Name','Yuksek');

% Bagil Nem
fis = addInput(fis,[0 100],'Name','BagilNem');
fis = addMF(fis,'BagilNem','trimf',[0   0   20],'Name','Kurak');
fis = addMF(fis,'BagilNem','trimf',[15  30  45],'Name','AzNemli');
fis = addMF(fis,'BagilNem','trimf',[40  60  80],'Name','Nemli');
fis = addMF(fis,'BagilNem','trimf',[75  100 100],'Name','CokNemli');

% 3. Çýktý Deðiþkeni: Sulama Süresi (0-60 dk)
fis = addOutput(fis,[0 60],'Name','SulamaSuresi');
fis = addMF(fis,'SulamaSuresi','trimf',[0   0    7.5],'Name','Kisa');
fis = addMF(fis,'SulamaSuresi','trimf',[15   20   45 ],'Name','Orta');
fis = addMF(fis,'SulamaSuresi','trimf',[40  60   60 ],'Name','Uzun');

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
tol     = 10;                          % 8 dakika tolerans
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

% 8. Hata Dagilimi Görselleþtirme
figure;
bar(derrors);
hold on;
yline(tol, 'r--', sprintf('Tolerans (%d dk)', tol));
xlabel('Test Numarasi');
ylabel('|Actual - Expected| (dk)');
title('Sulama Suresi Hata Dagilimi');
legend('Hata','Tolerans','Location','northoutside');