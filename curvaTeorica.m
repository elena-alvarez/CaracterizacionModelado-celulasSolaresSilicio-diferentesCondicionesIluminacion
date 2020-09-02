%Curva teorica
T=302; %Temperatura
K=1.38065*10^(-23); % Constante de Bolzan
Ns=36; %%NUmero de celdas en serie
q=1.6022*10^(-19);

if(~exist("Ig"))
 Ig =  0.32;
end
if(~exist("Isat"))
 Isat =  8.3e-07;
end
if(~exist("Rs"))
 Rs =  15;
end
if(~exist("A"))
 A =  1.5000;
end
if(~exist("Rp"))
 Rp = 1000000;
end
if(~exist("Ns"))
 Ns=36;
end
if(~exist("Voc"))
 Voc=20;
end

Vt=Ns*A*K*T/q;
clear Vmetodo
clear Imetodo

Vmetodo=[0:1:Voc];

index=1;
Imetodo(1)=Ig;
for V=Vmetodo
   if (index==1)
     Ip=Ig;
   else
     Ip=Imetodo(index-1);
   end   
   while((length(Imetodo)<index))
     Inew=Ig-Isat*(exp((V+Ip*Rs)/Vt)-1)-(V+Ip*Rs)/Rp;
     if (Inew>Ip)
       Imetodo(index)=0;
     else
       actualError=Ip-Inew;
       if(actualError < 0.01)%0.0001
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
%figure();
%plot(Vmetodo, Imetodo)
