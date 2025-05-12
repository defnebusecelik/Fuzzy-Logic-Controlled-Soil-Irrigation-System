# Fuzzy-Logic-Controlled-Soil-Irrigation-System

## BULANIK MANTIK İLE ÇEVRESEL FAKTÖRLERE GÖRE TOPRAK SULAMA SÜRESİNİN AYARLANMASI


Proje, tarımsal arazilerde toprak nemi, hava sıcaklığı, yağış miktarı, bitki su ihtiyacı ve bağıl nem gibi beş kritik çevresel değişkeni dikkate alarak Mamdani tipi bulanık mantık yaklaşımı ile sulama süresini optimize etmeyi amaçlar. Böylece su kaynaklarının etkin kullanımı, bitki sağlığının korunması ve verim artışı sağlanır.


#### Sistem Mimarisi


Denetleyici Türü :	Mamdani FIS
Girdi Sayısı :	5
Çıktı Sayısı :	1
Kural Sayısı :	1024
And İşlemi : Min
Or İşlemi : Max
Çıkarım Metodu : Min
Birleştirme Metodu : Max
Durulaştırma	: Centroid


Sistem, her bir girdi için tanımlı üyelik fonksiyonlarını kullanarak aşağıdaki üç aşamayı gerçekleştirir:
1.	Bulanıklaştırma (Fuzzification): Gerçek değerler, her bir üyelik fonksiyonunda derecelendirilir.
2.	Kural Değerlendirme (Inference): 1024 kural, max-min operatörleri aracılığıyla tetiklenir ve sonuçları toplanır.
3.	Kesinleştirme (Defuzzification): Toplanan bulanık sonuçlar, merkez ağırlık yöntemi ile tek bir sulama süresi değerine dönüştürülür.

   
#### Girdi Değişkenleri ve Üyelik Fonksiyonları


•	Toprak Nemi (0–100)


o	gaussmf: Kuru (σ=10, c=0)


o	gaussmf: AzNemli (σ=10, c=25)


o	gaussmf: OrtaNemli (σ=15, c=55)


o	gaussmf: ÇokNemli (σ≈14.57, c=100)


•	Hava Sıcaklığı (0–50°C)


o	gaussmf: Soğuk (σ=5, c=0)


o	gaussmf: Ilık (σ≈8.53, c=18)


o	gaussmf: Sıcak (σ≈7.50, c=35.1)


o	gaussmf: ÇokSıcak (σ=5, c=50)


•	Yağış (0–20 mm)


o	gaussmf: Yok (σ=0.5, c=0)


o	gaussmf: AzYağışlı (σ=2.75, c=3)


o	gaussmf: OrtaYağışlı (σ≈2.65, c=10)


o	gaussmf: ÇokYağışlı (σ=4, c=20)


•	Su İhtiyacı (0–10)


o	gaussmf: Düşük (σ=1, c=0)


o	gaussmf: BirazDüşük (σ≈1.33, c=3.5)


o	gaussmf: BirazYüksek (σ≈1.35, c=6.5)


o	gaussmf: Yüksek (σ=1.5, c=10)


•	Bağıl Nem (0–100)


o	gaussmf: Kurak (σ=10, c=0)


o	gaussmf: AzNemli (σ=15, c=30)


o	gaussmf: Nemli (σ=20, c=60)


o	gaussmf: ÇokNemli (σ=12.5, c=100)


Çıktı Değişkeni: Sulama Süresi


•	Aralık: 0–60 dakika


o	gaussmf: Kısa (σ=7.5, c=0)


o	gaussmf: Orta (σ=20, c=30)


o	gaussmf: Uzun (σ=10, c=60)


#### Uygulama Detayları
Bulanık mantık sistemi, MATLAB’in Fuzzy Logic Toolbox’u kullanılarak .fis dosyası biçiminde tanımlanmıştır. Uygulama süreci şu adımlardan oluşur:
1.	Girdi Verilerinin Hazırlanması: Toprak nemi, sıcaklık, yağış, bitki su ihtiyacı ve bağıl nem değerleri, sensörlerden gerçek zamanlı olarak elde edilir.
2.	Bulanık Değerlendirme: Girdileri alarak her bir üyelik fonksiyonundaki dereceleri hesaplar ve kural tabanındaki ilişkileri değerlendirir.
3.	Defuzzification: Ortaya çıkan bulanık sonuçlar, merkez ağırlık yöntemi (centroid) ile kesin bir sulama süresi değerine dönüştürülür.

   
Bu yapı, farklı bitki türleri ve iklim koşullarında kolayca parametre ayarı yapmaya, üyelik fonksiyonu şekillerini ve kural tabanını dinamik olarak güncellemeye olanak tanımaktadır.

