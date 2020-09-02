%%1.Lectura de Datos
%%%%Recogida de datos
%%Leer Datos
s=urlread('http://192.168.1.177');
datosIV=str2num(s);
%load("datos28MAyo.mat");
%datosIV(1,:)=datosIVTotal(1,:);
%datosIV(2,:)=datosIVTotal(2,:);
corriente=datosIV(1,:);
tension=datosIV(2,:);
figure()
plot(tension, corriente)
%%%Obtencion de puntos
ordenadosIV=fOrdenarVI(datosIV);
corriente=ordenadosIV(1,:);
tension=ordenadosIV(2,:);
Isc=max(corriente);
Voc=max(tension);
potencia=tension.*corriente;
pMaxMuestra=max(potencia);
[fila,columna]=find(potencia==pMaxMuestra);
Imp=corriente(columna);
Vmp=tension(columna);
datosIV=ordenadosIV;

metodoRW;
metodoXiao;
metodoSilva;
metodoVillalva;

figure()
subplot(2,2,1)
    plot(tension, corriente,'.r',Vmetodo_1, Imetodo_1,'-b')
    title('Método Randy Williams')
    xlabel('Tensión (V)')
    ylabel('Corriente (A)')
    grid
    legend('Curva Experimental','Curva Modelada','Location','SouthWest');
subplot(2,2,2)
    plot(tension, corriente,'.r',Vmetodo_2, Imetodo_2,'-b')
    title('Método Xiao')
    xlabel('Tensión (V)')
    ylabel('Corriente (A)')
    grid
    legend('Curva Experimental','Curva Modelada','Location','SouthWest');
subplot(2,2,3)
    plot(tension, corriente,'.r',Vmetodo_3, Imetodo_3,'-b')
    title('Método Silva')
    xlabel('Tensión (V)')
    ylabel('Corriente (A)')
    grid
    legend('Curva Experimental','Curva Modelada','Location','SouthWest');
subplot(2,2,4)
    plot(tension, corriente,'.r',Vmetodo_4, Imetodo_4,'-b')
    title('Método Villalva')
    xlabel('Tensión (V)')
    ylabel('Corriente (A)')
    grid
    legend('Curva Experimental','Curva Modelada','Location','SouthWest');

%%%Potencia
    
figure()
subplot(2,2,1)
    plot(tension, (corriente.*tension),'.r',Vmetodo_1, (Vmetodo_1.*Imetodo_1),'-b')
    title('Método Randy Williams')
    xlabel('Tensión (V)')
    ylabel('Potencia (W)')
    grid
    legend('Curva Experimental','Curva Modelada','Location','SouthWest');
subplot(2,2,2)
    plot(tension, (corriente.*tension),'.r',Vmetodo_2, (Vmetodo_2.*Imetodo_2),'-b')
    title('Método Xiao')
    xlabel('Tensión (V)')
    ylabel('Potencia (W)')
    grid
    legend('Curva Experimental','Curva Modelada','Location','SouthWest');
subplot(2,2,3)
    plot(tension, (corriente.*tension),'.r',Vmetodo_3,(Vmetodo_3.*Imetodo_3),'-b')
    title('Método Silva')
    xlabel('Tensión (V)')
    ylabel('Potencia (W)')
    grid
    legend('Curva Experimental','Curva Modelada','Location','SouthWest');
subplot(2,2,4)
    plot(tension, (corriente.*tension),'.r',Vmetodo_4, (Vmetodo_4.*Imetodo_4),'-b')
    title('Método Villalva')
    xlabel('Tensión (V)')
    ylabel('Potencia (W)')
    grid
    legend('Curva Experimental','Curva Modelada','Location','SouthWest');
    
ParametrosObtenidos=table(ParametrosRW, ParametrosXiao, ParametrosSilva, ParametrosVillalva,'RowNames',{'Ig','A','Isat','Rs','Rp'})
Experimentales=[Isc;Voc;pMaxMuestra;Imp;Vmp];
Parametros_Experimentales_Vs_Modelados=table(Experimentales,MetodoRW,MetodoXiao,MetodoSilva,MetodoVillalva,'RowNames',{'Isc', 'Voc','Pm','Impp','Vmpp'})

figure()
plot(tension, corriente,'.r',Vmetodo_1, Imetodo_1,'sb',Vmetodo_2, Imetodo_2,'<k',Vmetodo_3, Imetodo_3,'-g',Vmetodo_4, Imetodo_4,'xc');
legend('Curva Experimental','Curva Método RW','Curva Método Xiao','Curva Método Silva','Curva Método Villalva','Location','SouthWest');
title('Comparación de Métodos')
xlabel('Tensión (V)')
ylabel('Corriente (A)')
grid