clear Ig
clear Isat
clear A
clear Rs
clear Rp
%%-----------------

% Articulo Randy Willians Fonseca

Iph  = Isc;
numeradorVt  =(2*Vmp-Voc)*(Isc-Imp);
denominadorVt=Isc+((Isc-Imp)*log(1-(Imp/Isc)));
Vt=numeradorVt/denominadorVt;
Io=Isc*exp(-Voc/Vt);
Rs=(Vt*log(1-(Imp/Isc)))+Voc-Vmp;
Rs=Rs/Imp;

clear V_metodo1
clear I_metodo1

Ig=Iph;
Isat=Io;
T=302; %Temperatura
K=1.38065*10^(-23); % Constante de Bolzan
Ns=36; %%NUmero de celdas en serie
q=1.6022*10^(-19);
A=Vt*q/(Ns*K*T);

curvaTeorica;

Vmetodo_1=Vmetodo;
Imetodo_1=Imetodo;

figure(1);
plot(tension, corriente,'.r',Vmetodo_1, Imetodo_1)

xlabel('Tension(V)');
ylabel('Corriente(A)');
suptitle('Curva I-V MetodoRW Vs Curva I-V Experimental');
title('Modelo de 4 Parametros');
grid
legend('Curva Experimental','Curva Modelada','Location','SouthWest');
Rptabla=inf;
ParametrosRW=[Ig; A; Isat; Rs;Rptabla];

VocMetodo1=max(Vmetodo_1);
IscMetodo1=max(Imetodo_1);
potenciaMetodo1=Vmetodo_1.*Imetodo_1;
PmMetodo1=max(potenciaMetodo1);
[fila1,columna1]=find(potenciaMetodo1==PmMetodo1);
ImpMetodo1=Imetodo_1(columna1);
VmpMetodo1=Vmetodo_1(columna1);

MetodoRW=[IscMetodo1;VocMetodo1;PmMetodo1;ImpMetodo1;VmpMetodo1];

