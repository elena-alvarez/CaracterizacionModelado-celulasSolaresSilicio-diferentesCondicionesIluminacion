% xiao method
clear Ig
clear Isat
clear A
clear Rs
clear Rp
%%datosIV contiene las muestras de datos reales
clear datosSinCeros
indiceSinCeros=1;
for indice=[1:1:length(datosIV)]
  if (~((datosIV(1,indice) == 0)&(datosIV(2,indice) == 0)))
     datosSinCeros(1,indiceSinCeros)=datosIV(1,indice);
     datosSinCeros(2,indiceSinCeros)=datosIV(2,indice);
     indiceSinCeros=indiceSinCeros+1;
  end
end
clear ordenadosIV
ordenadosIV=fOrdenarVI(datosSinCeros);
%% Parametros de la placa
Isc = max(ordenadosIV(1,:));
Voc = max(ordenadosIV(2,:));
potenciaMuestra=ordenadosIV(1,:).*ordenadosIV(2,:);
pMaxMuestra=max(potenciaMuestra);
indiceMaxPotMuestra=find(potenciaMuestra==pMaxMuestra);
Imp = ordenadosIV(1,indiceMaxPotMuestra);
Vmp = ordenadosIV(2,indiceMaxPotMuestra);

%%Constantes
T=302; %Temperatura
K=1.38065*10^(-23); % Constante de Bolzan
Ns=36;%%NUmero de celdas en serie
q=1.6022*10^(-19);

columnaErrorMatriz=1;
Ig=Isc;


for A=[1:0.05:2]
    Vt=(Ns*A*K*T)/q;  %%2
    Isat =Ig/(exp(Voc/Vt)-1);  %%11
    %eq 13
    Rs=(Vt*log(((1-Imp/Ig)*exp(Voc/Vt)+Imp/Ig))-Vmp)/Imp;
    clear Vmetodo
    clear Imetodo
    Vmetodo=ordenadosIV(2,:);
    Imetodo(1)=Ig;
    index=1;
      for V=Vmetodo
          %tension=V;
          index=index;
          if (index==1)
              Ip=Ig;
          else
              Ip=Imetodo(index-1);
          end   
          while((length(Imetodo)<index))
               Inew=Ig-Isat*(exp((V+Ip*Rs)/Vt)-1);  %%-(V+Ip*Rs)/Rp;
               if (Inew>Ip)
                  %printf("Ines mayor que IP\n");
                  Ip=Ip;
                  Inew=Inew;
                  Imetodo(index)=0;
               else
                  actualError=Ip-Inew;
                  if(actualError < 0.0001)
                    if (Inew  < 0)
                        Imetodo(index)=0;
                    else
                        Imetodo(index)=Inew;
                    end
                  end
               end
               Ip=Ip-0.00001;
          end
          index=index+1;
      end
    potenciaModelo=Imetodo.*Vmetodo;
    potenciaModeloMax=max(potenciaModelo);
    
    [filaModelo,columnaModelo]=find(potenciaModelo==potenciaModeloMax);
    ImpModelo=Imetodo(columnaModelo);
    VmpModelo=Vmetodo(columnaModelo);
    
    exponente=(VmpModelo+ImpModelo*Rs)/Vt;
    numerador=(Isat/Vt)*exp(exponente);
    denominador=1+(Isat*Rs/Vt)*exp(exponente);
    t1=numerador/denominador;
    t2=ImpModelo/VmpModelo;
    errorTotal=t2-t1;
  
    
    errorMatriz(1,columnaErrorMatriz)=errorTotal;
    errorMatriz;
    columnaErrorMatriz=columnaErrorMatriz+1;
end

errorMinimo=min(errorMatriz);
[filaError,columnaError]=find(errorMatriz==errorMinimo);
errorMatriz(filaError,columnaError);
matrizA=[1:0.05:2];
Aoptimo=matrizA(filaError,columnaError);

A=Aoptimo;
Vt=(Ns*Aoptimo*K*T)/q;
Isat =Ig/(exp(Voc/Vt)-1);
Rs=(Vt*log(((1-Imp/Ig)*exp(Voc/Vt)+Imp/Ig))-Vmp)/Imp;

curvaTeorica;

Vmetodo_2=Vmetodo;
Imetodo_2=Imetodo;
figure(2);
plot(tension, corriente,'.r',Vmetodo_2, Imetodo_2)

xlabel('Tension(V)');
ylabel('Corriente(A)');
suptitle('Curva I-V MetodoXiao Vs Curva I-V Experimental');
title('Modelo de 4 Parametros');
grid
legend('Curva Experimental','Curva Modelada','Location','SouthWest');
Rptabla=inf;

ParametrosXiao=[Ig; Aoptimo; Isat; Rs;Rptabla];
%ParametrosMetodoXiao=table(ParametrosXiao,'RowNames',{'Ig','A','Isat','Rs','Rp'})
VocMetodo2=max(Vmetodo_2);
IscMetodo2=max(Imetodo_2);
potenciaMetodo2=Vmetodo_2.*Imetodo_2;
PmMetodo2=max(potenciaMetodo2);
[fila2,columna2]=find(potenciaMetodo2==PmMetodo2);
ImpMetodo2=Imetodo_2(columna2);
VmpMetodo2=Vmetodo_2(columna2);

MetodoXiao=[IscMetodo2;VocMetodo2;PmMetodo2;ImpMetodo2;VmpMetodo2];