clear all
close all
clc

%% CASO MONOSTADIO - R134a
% DATI PROBLEMA
fluid='R134a';
T_B=-12; %°C
T_A_vett=[35 45 60];  %°C
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
    
 
 % m(i)=Qco/(h2-h3); questa parte qui non serve!
 
 %Cambia, per lo stesso motivo, la potenza da fornire al compressore
 % L=m(i)*(h2-h1);
 
 %Calcolo il COP che sarà sempre variabile con i
 % COP(i)=Qco/L;
 
 
%% GRAFICO PIANO p-h
% Per individuare la curva trovo la p critica e una p minima da cui far
% partire la curva

pcr=refpropm('p','C',0,' ',0,fluid)/100;
pmin=p1-1;
 
% Creo un vettore di p che va dalla pressione minima a quella critica
p_vett=pmin:0.1:pcr;

%Creo i vettori di entalpia per il vapore e il liquido saturo
for j=1:length(p_vett)-1
    h_L(j)=refpropm('h','p',p_vett(j)*100,'q',0,fluid)/1000;
    h_s(j)=refpropm('h','p',p_vett(j)*100,'q',1,fluid)/1000;
end
 % Per chiudere la campana
hcr=refpropm('h','C',0,' ',0,fluid)/1000;
h_L(length(p_vett))=hcr;
h_s(length(p_vett))=hcr;

%Isobara 4-1
p_vett1=linspace(p4,p1,10);
h_1=linspace(h4,h1,10);
%Isoentropica 1-2s
p_vett2s=linspace(p1,p2s,80);
for k=1:length(p_vett2s)-1
    h_2s(k)=refpropm('h','p',p_vett2s(k)*100,'s',s1*1000,fluid)/1000;
end
h_2s(length(p_vett2s))=h2s;
%Line 1-2
p_vett2=[p1 p2];
h_2=[h1 h2];
%Isobara 2-3
p_vett3=linspace(p2,p3,10);
h_3=linspace(h2,h3,10);
%Isoentalpica 3-4
p_vett4=linspace(p3,p4,10);
h_4=linspace(h3,h4,10);

figure(i)
semilogy(h_L,p_vett,'b','linewidth',1.5)
hold on
semilogy(h_s,p_vett,'b','linewidth',1.5)
hold on
semilogy(h_1,p_vett1,'r','linewidth',1.5)
hold on
semilogy(h_2s,p_vett2s,'r','linewidth',1.5)
hold on
semilogy(h_2,p_vett2,'--r','linewidth',1.5)
hold on
semilogy(h_3,p_vett3,'r','linewidth',1.5)
hold on
semilogy(h_4,p_vett4,'--r','linewidth',1.5)

xlabel('Entalpia Specifica [kJ/kg]','FontName','Times','FontSize',18,'FontWeight','Bold')
ylabel('Pressione [bar]','FontName','Times','FontSize',18,'FontWeight','Bold') 
set(gca,'FontName','Times','FontSize',18,'FontWeight','Bold')
title('Diagramma p-h. Caso monostadio-R134a','FontName','Times','FontSize',20,'FontWeight','Bold')
plot([h1 h2s h2 h3 h4],[p1 p2s p2 p3 p4],'ko','MarkerFaceColor','k','MarkerSize',6)
end

