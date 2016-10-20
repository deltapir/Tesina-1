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
    
 %% GRAFICO COP AL VARIARE DELLA Tco
 % questa parte qui in questo codice non serve. Questo codice serve solo
 % per proiettare le trasformazioni sul piano T-s.
 
 % Poichè cambia T_A e quindi i punti del ciclo, cambierà anche la portata
 % necessaria per assicurare la Qco di progetto (che è fissa)
 % m(i)=Qco/(h2-h3);
 
 %Cambia, per lo stesso motivo, la potenza da fornire al compressore
 % L=m(i)*(h2-h1);
 
 %Calcolo il COP che sarà sempre variabile con i
 % COP(i)=Qco/L;

%% GRAFICO PIANO T-s
% Individuazione T critica e T minima
Tcr=refpropm('T','C',0,' ',0,fluid)-273.15;
Tmin=T4-10;
%Creo un vettore di T che vanno da quella minima a quella critica
T_vett=Tmin:0.1:Tcr;
%Creo i vettori di entropia per il liquido e il vapore
for j=1:length(T_vett)-1;
    s_L(j)=refpropm('s','T',T_vett(j)+273.15,'q',0,fluid)/1000;
    s_V(j)=refpropm('s','T',T_vett(j)+273.15,'q',1,fluid)/1000;
end
%Per chiudere la campana trovo la s del punto critico
scr=refpropm('s','C',0,' ',0,fluid)/1000;
s_L(length(T_vett))=scr;
s_V(length(T_vett))=scr;

%Isobara pev sotto campana
s_in=refpropm('s','T',Tev+273.15,'q',0,fluid)/1000;
s_fin=refpropm('s','T',Tev+273.15,'q',1,fluid)/1000;
s_vett=linspace(s_in,s_fin,100);
for k=1:length(s_vett)-1
    T_sc(k)=Tev;
end
T_sc(length(s_vett))=Tev;

%Isobara pev fuori campana
Tv=T1;
TV=Tev;
sM=refpropm('s','T',Tev+273.15,'q',1,fluid)/1000;
T_vett3=linspace(Tv,TV,100);
for z=1:length(T_vett3)-1
    s_FC(z)=refpropm('s','T',T_vett3(z)+273.15,'p',pev*100,fluid)/1000;
end
s_FC(length(T_vett3))=sM;

%Isobara pco sotto campana
s_i=s3;
s_f=refpropm('s','T',Tco+273.15,'q',1,fluid)/1000;
s_vett2=linspace(s_i,s_f,100);
for l=1:length(s_vett2)-1
    T_s(l)=Tco;
end
T_s(length(s_vett2))=Tco;

%Isobara pco fuori campana
Tm=T2;
TM=Tco;
sM=refpropm('s','T',Tco+273.15,'q',1,fluid)/1000;
T_vett2=linspace(Tm,TM,100);
for y=1:length(T_vett2)-1
    s_fc(y)=refpropm('s','T',T_vett2(y)+273.15,'p',pco*100,fluid)/1000;
end
s_fc(length(T_vett2))=sM;

%Isoentalpica 3-4
T_vett4=linspace(T3,T4,100);
for n=1:length(T_vett4)-1
    s_ent(n)=refpropm('s','T',T_vett4(n)+273.15,'h',h4*1000,fluid)/1000;
end
s_ent(length(T_vett4))=s4;

%Isoentropica 1-2s
T2s=refpropm('T','p',pco*100,'s',s2s*1000,fluid)-273.15;
T_vett5=linspace(T1,T2s,100);
for m=1:length(T_vett5)-1
    s_is(m)=s1;
end
s_is(length(T_vett5))=s2s;

%Compressione 1-2
T_vett6=linspace(T1,T2,2);
s_compr=linspace(s1,s2,2);

figure (i)
 plot(s_L,T_vett,'k','linewidth',1.5)
 hold on
 plot(s_V,T_vett,'k','linewidth',1.5)
 hold on
 plot(s_vett,T_sc,'b','linewidth',1.0)
 hold on
 plot(s_vett2,T_s,'b','linewidth',1.0)
 hold on
 plot(s_fc,T_vett2,'b','linewidth',1.0)
 hold on
 plot(s_FC,T_vett3,'b','linewidth',1.0)
 hold on
 plot(s_ent,T_vett4,'--b','linewidth',1.0)
 hold on
 plot(s_is,T_vett5,'b','linewidth',1.0)
 hold on
 plot(s_compr,T_vett6,'--b','linewidth',1.0)
 
 xlabel('Entropia Specifica [kJ/kg K]','FontName','Times','FontSize',18,'FontWeight','Bold')
 ylabel('Temperatura [°C]','FontName','Times','FontSize',18,'FontWeight','Bold') 
 set(gca,'FontName','Times','FontSize',18,'FontWeight','Bold')
 title('Diagramma T-s. Caso monostadio-R134a','FontName','Times','FontSize',20,'FontWeight','Bold')
 
 plot([s1 s2 s3 s4 s2s],[T1 T2 T3 T4 T2s],'ko','MarkerFaceColor','k','MarkerSize',6)
 
end





