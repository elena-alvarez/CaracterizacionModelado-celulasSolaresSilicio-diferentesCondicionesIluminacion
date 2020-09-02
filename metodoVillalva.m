clear Ig
clear Isat
clear A
clear Rs
clear Rp
% Villalva Method
metodo="Villalva Method";
%%Recibe los parametros de la placa.
%%Si no estan definidos tomamos valores de prueba
if(~exist("Isc"))
   Isc=0.32;
end
if(~exist("Voc"))
  Voc=22.0;
end
if(~exist("Imp"))
  Imp=0.29;
end
if(~exist("Vmp"))
  Vmp=17.5;
end
if(~exist("pMaxMuestra"))
  pMaxMuestra=5;
end 
%%Constantes
T=302; %Temperatura
K=1.38065*10^(-23); % Constante de Bolzan
Ns=36; %%NUmero de celdas en serie
q=1.6022*10^(-19); %Carga del electron

clear Vgrafica 
clear Igrafica

%vease diagrama de fuljo pag 281
A=1.3;
%eq 11
Ig=Isc;
Vt=(Ns*A*K*T)/q ;
Isat=Ig/(exp(Voc/Vt)-1);
%proponemos
Rs=0;
Rpmin=(Vmp/(Isc-Imp))-((Voc-Vmp)/Imp);
Rp=Rpmin;

%Para eq 15
PmpCurve=pMaxMuestra;

%Inicio del bucle
errorPmax=100;
while ((errorPmax > 0.005) && (Rs<50))
  %solve eq 7
  Ig=Isc;
  %solve eq 15
  exponenteIsat=(Vmp+(Rs*Imp))/Vt;
  RpNumerador  =Vmp*(Vmp+Rs*Imp);
  RpDenom=Vmp*(Ig-Isat*(exp(exponenteIsat)-1));
  RpDenom=RpDenom-PmpCurve;
  Rp=RpNumerador/RpDenom;
  
  if (Rp<0)
    Rs=Rs+0.1;
    continue
  end
  
  %solve Eq 16
  Ig=(Rp+Rs)*Isc/Rp;
  
  
  curvaTeorica;
  
  Vgrafica=Vmetodo;
  Igrafica=Imetodo;

%% Calculo de potencia del modelo
pGrafica = Vgrafica.*Igrafica;
pGraficaMax = max(pGrafica);

errorPmax=abs(pGraficaMax-pMaxMuestra);

Rs=Rs+0.1;

 
end %errorPmax
Rs ;
Rp ;
Ig ;
Isat ;
A;
Vmetodo_4=Vmetodo;
Imetodo_4=Imetodo;

figure();
plot(tension, corriente,'.r',Vmetodo_4, Imetodo_4)

xlabel('Tension(V)');
ylabel('Corriente(A)');
suptitle('Curva I-V Modelo Villalva Vs Curva I-V Experimental');
title('Modelo de 5 Parametros');
grid
legend('Curva Experimental','Curva Modelada','Location','SouthWest');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ParametrosVillalva=[Ig; A; Isat; Rs; Rp];
%ParametrosMetodoVillalva=table(ParametrosVillalva,'RowNames',{'Ig','A','Isat','Rs','Rp'})
VocMetodo4=max(Vmetodo_4);
IscMetodo4=max(Imetodo_4);
potenciaMetodo4=Vmetodo_4.*Imetodo_4;
PmMetodo4=max(potenciaMetodo4);
[fila4,columna4]=find(potenciaMetodo4==PmMetodo4);
ImpMetodo4=Imetodo_4(columna4);
VmpMetodo4=Vmetodo_4(columna4);

MetodoVillalva=[IscMetodo4;VocMetodo4;PmMetodo4;ImpMetodo4;VmpMetodo4];