%FIR COM FASE LINEAR - EQUA��O T4 - BANDPASS

clear all
close all

%Ordem do filtro (�mpar, valor dado)
L = 31; 

%Frequ�ncia de corte inferior (Valor Dado)
fcl = 7e3;

%Frequ�ncia de corte superior (Valor Dado)
fc2 = 28e3;

%Frequ�ncia de amostragem (Valor Dado)
Fs = 70e3;

%Frequ�ncia de corte normalizadas, pois a fun��o firls exige isso
freq2 = 2*fc2/Fs;
freq1 = 2*fcl/Fs;

%Vetor com as frequ�ncias de corte
freq = [0 freq1/2 freq1 freq2 (1-freq1/2) 1];

%Vetor Amplitudes para interpolariza��o, requerido pela fun��o do matlab
amp = [0 0 1 1 0 0];


% Calculo dos coeficientes de h
h = firls(L,freq,amp,'h');

%Grafico dos coeficientes de h discretos
figure(1)
subplot(2,1,1)
stem(0:L,h)
title('Coeficientes (simetria impar)');
xlabel('�ndice n'); ylabel('valor do coeficiente');

%Intervalo omega discreto que ser�o os pontos utilizado no gr�fico
omegadis = 0:0.01:pi;
for l = 1:length(omegadis)
   for n= 0:(L-1)/2
    valores(n+1) = 2*h(n+1)*sin(omegadis(l)*(n - (L/2)));
    end
    soma = sum(valores);
    H(l)= exp(-i*((omegadis(l)*(L/2)) + (pi/2)) )*soma;
end

figure(3)
plot(omegadis/pi,abs(H),'-b');grid minor
title('Resposta de Frequ�ncia');
xlabel('Omega normalizado'); ylabel('Magnitude');

%Quantiza��o

%Cria��o de uma variavel chamada htemp para se manipular os coeficientes do
%filtro
htemp = h;

%Parte em que � determinado o bit de sinal e armazenado em hsinal
for m=1:length(htemp)
    
 
    if htemp(m) < 0        
        
        hsinal(m)= 1;
        
        htemp(m) = -1*htemp(m);
    
    else
        
        hsinal(m) = 0;
    end  
   
     % trasnforma��o em bin�rio
    for s = 2:8
            htemp(m) = htemp(m)*2;
            
            if htemp(m) < 1  
            
                hbin(m,s) = 0;
            
            end 
            if htemp(m) > 1
                
                hbin(m,s) = 1;
                
                htemp(m) = htemp(m) - fix(htemp(m));
            end
            
            
    end
    
end


hquan = zeros(1,length(h));

for a = 1:length(h)
    
    %Passando os n�meros de binario para decimal
    for m = 2:8 
        hquan(a) = hquan(a)+ hbin(a,m)*(2^(-m+1));
    end
    
    if hsinal(a) == 1 %Analizando o sinal dos coeficientes
        hquan(a) = hquan(a)*(-1);
    end
end

figure(1)
subplot(2,1,2)
stem(0:L,hquan)
title('Coeficientes Quantizados');
xlabel('�ndice n'); ylabel('valor do coeficiente');


% Calculo e plot de H3 com coeficientes de 8 bits equa��o 8.12
for l = 1:length(omegadis)
    for n = 0:(L-1)/2
        valores(n+1) = 2*hquan(n+1)*sin(omegadis(l)*(n - (L/2)));
    end
    soma = sum(valores);
    Hquan(l) = exp(-i* ( (omegadis(l)*(L/2)) + (pi/2)) )*soma;
end

figure(3)
plot(omegadis/pi,abs(Hquan),'-b');grid minor
title('Resposta de Frequ�ncia Quantizado');
xlabel('Omega normalizado'); ylabel('Magnitude');

%Gr�ficos
figure
subplot(2,1,1)
plot(omegadis/pi,abs(H),'-b');grid minor
hold

plot(omegadis/pi,abs(Hquan),':r'); grid minor
title('M�dulo de H (azul- M�dulo de Fun��o H e vermelho- H quantizado)');
xlabel('Omega normalizado'); ylabel('Magnitude');

subplot(2,1,2)
plot(omegadis/pi,angle(H),'-b');grid minor
hold

plot(omegadis/pi,angle(Hquan),':r'); grid minor
title('Fase de H');
xlabel('Omega normalizado'); ylabel('Fase');


