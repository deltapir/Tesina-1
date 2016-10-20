clear all
close all
clc

%% CASO MONOSTADIO - R1234yf 
%DATI PROBLEMA
fluid='R1234yf';
T_B=-12; %°C
T_A_vett=35:1:60;  %°C
DT_min_ev=8;
DT_min_co=8;
DT_sur=3;
Qco=10;  %KW

a=-2.648;   
b=1.553;
c=0.6085;

for i=1:length(T_A_vett)
    T_A=T_A_vett(i);
    
    T1=T_B-DT_min_ev;
    Tev=T_B-DT_sur-DT_min_ev;
    pev=refpropm('p','T',Tev+273.15,'q',1,fluid)/100;
    p1=pev;
    s1=refpropm('s','T',T1+273.15,'p',p1*100,fluid)/1000;
    h1=refpropm('h','T',T1+273.15,'p',p1*100,fluid)/1000;
    
    s2s=s1;
    Tco=T_A+DT_min_co;
    pco=refpropm('p','T',Tco+273.15,'q',1,fluid)/100;
    p2s=pco;
    h2s=refpropm('h','p',p2s*100,'s',s2s*1000,fluid)/1000;
    
    beta_c=p2s/p1;
    eta_c=a*exp(-b*beta_c)+c;
    h2=((h2s-h1)/eta_c)+h1;
    p2=p2s;
    T2=refpropm('T','p',p2s*100,'h',h2*1000,fluid)-273.15;
    s2=refpropm('s','p',p2s*100,'h',h2*1000,fluid)/1000;
    
    p3=p2;
    T3=refpropm('T','p',p3*100,'q',0,fluid)-273.15;
    s3=refpropm('s','p',p3*100,'q',0,fluid)/1000;
    h3=refpropm('h','p',p3*100,'q',0,fluid)/1000;
    
    h4=h3;
    p4=p1;
    T4=Tev;
    s4=refpropm('s','p',p4*100,'h',h4*1000,fluid)/1000;
    q4=refpropm('q','p',p3*100,'h',h4*1000,fluid);

    %% GRAFICO COP AL VARIARE DELLA Tco
 % Poichè cambia T_A e quindi i punti del ciclo, cambierà anche la portata
 % necessaria per assicurare la Qco di progetto (che è fissa)

 m(i)=Qco/(h2-h3);
 
%Cambia, per lo stesso motivo, la potenza da fornire al compressore
 L=m(i)*(h2-h1);
 
 %Calcolo il COP che sarà sempre variabile con i
 COP(i)=Qco/L;
 T_co(i)=Tco;
end

plot(T_co,COP,'r','MarkerFaceColor','k','linewidth',1.0)
hold on
plot([T_co(1) T_co(11) T_co(26)],[COP(1) COP(11) COP(26)],'ko','MarkerFaceColor','k','MarkerSize',6)
% creando un vettore di T_A dai valori 35 a 60 con passo uno, so che il
% vettore ha in totale 26 valori. Analogamente avranno lo stesso numero di
% valori i vettori T_co e COP. Al primo valore di T_A corrispondono 35
% gradi, all'undicesimo 45 e all'ultimo, il ventiseiesimo 60 (questo l'ho
% ricavato in maniera molto grezza e brutale...contanto sulle dita...
xlabel('Tco','FontName','Times','FontSize',18,'FontWeight','Bold')
ylabel('COP','FontName','Times','FontSize',18,'FontWeight','Bold') 
set(gca,'FontName','Times','FontSize',18,'FontWeight','Bold')
title('COP vs Tco. Caso monostadio-R1234yf','FontName','Times','FontSize',20,'FontWeight','Bold')
