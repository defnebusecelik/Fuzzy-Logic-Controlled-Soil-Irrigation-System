% irrigation_control_gbellmf.m: Mamdani Bulanýk Sulama Kontrol Scripti (Genel Çan - gbellmf) - Tam Kural Tabaný
clear; close all; clc;

% 1. FIS Oluþturma
fis = newfis('IrrigationControl','mamdani');

% 2. Girdi Deðiþkenleri ve Genel Çan (gbellmf) Üyelik Fonksiyonlarý
% Toprak Nem (0–100)
fis = addInput(fis,[0 100],'Name','ToprakNem');
fis = addMF(fis,'ToprakNem','gbellmf',[10 2   0],'Name','Kuru');
fis = addMF(fis,'ToprakNem','gbellmf',[10 2  25],'Name','AzNemli');
fis = addMF(fis,'ToprakNem','gbellmf',[15 2  55],'Name','OrtaNemli');
fis = addMF(fis,'ToprakNem','gbellmf',[17.5 2 100],'Name','CokNemli');

% Sýcaklýk (0–50)
fis = addInput(fis,[0 50],'Name','Sicaklik');
fis = addMF(fis,'Sicaklik','gbellmf',[5  2   0],'Name','Soguk');
fis = addMF(fis,'Sicaklik','gbellmf',[10 2  18],'Name','Ilik');
fis = addMF(fis,'Sicaklik','gbellmf',[10 2  35],'Name','Sicak');
fis = addMF(fis,'Sicaklik','gbellmf',[5  2  50],'Name','CokSicak');

% Yaðýþ (0–20)
fis = addInput(fis,[0 20],'Name','Yagis');
fis = addMF(fis,'Yagis','gbellmf',[0.5 2   0],'Name','Yok');
fis = addMF(fis,'Yagis','gbellmf',[2.75 2  3],'Name','AzYagisli');
fis = addMF(fis,'Yagis','gbellmf',[5    2 10],'Name','OrtaYagisli');
fis = addMF(fis,'Yagis','gbellmf',[4    2 20],'Name','CokYagisli');

% Ürün Su Ýhtiyacý (0–10)
fis = addInput(fis,[0 10],'Name','UrunSuIhtiyaci');
fis = addMF(fis,'UrunSuIhtiyaci','gbellmf',[1    2   0],'Name','Dusuk');
fis = addMF(fis,'UrunSuIhtiyaci','gbellmf',[1.75 2   3.5],'Name','OrtaDusuk');
fis = addMF(fis,'UrunSuIhtiyaci','gbellmf',[1.75 2   6.5],'Name','OrtaYuksek');
fis = addMF(fis,'UrunSuIhtiyaci','gbellmf',[1.5  2  10],'Name','Yuksek');

% Baðýl Nem (0–100)
fis = addInput(fis,[0 100],'Name','BagilNem');
fis = addMF(fis,'BagilNem','gbellmf',[10   2   0],'Name','Kurak');
fis = addMF(fis,'BagilNem','gbellmf',[15   2  30],'Name','AzNemli');
fis = addMF(fis,'BagilNem','gbellmf',[20   2  60],'Name','Nemli');
fis = addMF(fis,'BagilNem','gbellmf',[12.5 2 100],'Name','CokNemli');

% 3. Çýktý Deðiþkeni: Sulama Süresi (0–60 dk) – Genel Çan Üyelik Fonksiyonlarý
fis = addOutput(fis,[0 60],'Name','SulamaSuresi');
fis = addMF(fis,'SulamaSuresi','gbellmf',[7.5 2   0],'Name','Kisa');
fis = addMF(fis,'SulamaSuresi','gbellmf',[20  2  30],'Name','Orta');
fis = addMF(fis,'SulamaSuresi','gbellmf',[10  2  60],'Name','Uzun');

% 4. Kural Tabaný Oluþturma (4^5 = 1024 kural)
ruleList = [];
for tn = 1:4
    for sk = 1:4
        for yg = 1:4
            for ui = 1:4
                for bn = 1:4
                    memAvg = mean([tn, sk, yg, ui, bn]);
                    % cs: 1=Kisa, 2=Orta, 3=Uzun
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

% 8. Hata Daðýlýmýný Görselleþtirme
figure;
bar(derrors);
hold on;
yline(tol, 'r--', sprintf('Tolerans (%d dk)', tol));
xlabel('Test Numarasi');
ylabel('|Actual - Expected| (dk)');
title('Sulama Suresi Hata Dagilimi (Genel Çan Üyelik)');
legend('Hata','Tolerans','Location','northoutside');
