clear all
close all
clc

%% CASO MONOSTADIO - R1234yf 
%DATI PROBLEMA
%fluid={'R1234yf' 'R245fa' 'R134a'};
T_B=-12; %°C
%T_A_vett=[35 45 60];  %°C
T_A=60;
DT_min_ev=8;
DT_min_co=8;
DT_sur=3;
Qco=10;  %KW
q5=0;
q7=1;

a=-2.648;   
b=1.553;
c=0.6085;
CIL={[1.5767 2.8955] [4.1998 49.0207] [1.1539 3.5903]}; %r1234yf r245fa r134a | cilindrata alta, cilindrata bassa
%anche se dovremmo fissare un fluido. Quindi alla fine abbiamo un solo
%valore di cilindrata.
%fisso il R1234yf

fluid='R1234yf';

%fisso la temperatura a 60°C
%fisso la cilindrata

CILb=2.8955/1000;

%%CASO BISTADIO

    T1=T_B-DT_min_ev;
    Tev=T_B-DT_sur-DT_min_ev;
    Tco=T_A+DT_min_co;
    
    Tintvett=linspace(Tev,Tco-1,50);
    for j=1:length(Tintvett);
        
        pint(j)=refpropm('p','t',Tintvett(j)+273.15,'q',0,fluid)/100;
  
        %% Calcolo delle proprietà
    
        %punto 1
    pev=refpropm('p','T',Tev+273.15,'q',1,fluid)/100;
    p1=pev;
    s1=refpropm('s','T',T1+273.15,'p',p1*100,fluid)/1000;
    h1=refpropm('h','T',T1+273.15,'p',p1*100,fluid)/1000;
    rho1=refpropm('d','p',p1*100,'h',h1*1000,fluid); %densità dell'aria aspirata al punto 1
    
    %punti 2s e 2
    s2s=s1;
    pco=refpropm('p','T',Tco+273.15,'q',1,fluid)/100;
    p2s=pco;
    T2s=refpropm('T','p',p2s*100,'s',s2s*1000,fluid)-273.15;
    h2s=refpropm('h','p',p2s*100,'s',s2s*1000,fluid)/1000;
    
    beta_c1=p2s/p1;
    eta_c1=a*10^(-b*beta_c1)+c;
    h2=((h2s-h1)/eta_c1)+h1;
    p2=p2s;
    T2=refpropm('T','p',p2s*100,'h',h2*1000,fluid)-273.15;
    s2=refpropm('s','p',p2s*100,'h',h2*1000,fluid)/1000;
        
    %punto 7
    p7=pint(j);
    T7=refpropm('t','p',pint(j)*100,'q',q7,fluid)-273.15;
    h7=refpropm('h','t',T7+273.15,'q',q7,fluid)/1000;
    s7=refpropm('s','t',T7+273.15,'q',q7,fluid)/1000;
    
    %punti 3s e 3
    s3s=s7;
    p3s=pco;
    h3s=refpropm('h','p',p3s*100,'s',s3s*1000,fluid)/1000;
    T3s=refpropm('T','p',p3s*100,'h',h3s*1000,fluid)-273.15;
    
    beta_c2=p3s/p7;
    eta_c2=a*exp(-b*beta_c2)+c;
    h3=((h3s-h7)/eta_c2)+h7;
    p3=p3s;
    T3=refpropm('T','p',p3s*100,'h',h3*1000,fluid)-273.15;
    s3=refpropm('s','p',p3s*100,'h',h3*1000,fluid)/1000;
    
    %punto 4
    T4=(T2+T3)/2;
    p4=p3;
    h4(j)=refpropm('h','t',T4+273.15,'p',p4*100,fluid)/1000;
    s4=refpropm('s','t',T4+273.15,'p',p4*100,fluid)/1000;
    
    %punto 5
    p5=p2;
    T5=refpropm('t','p',p5*100,'q',q5,fluid)-273.15;
    s5=refpropm('s','t',T5+273.15,'q',q5,fluid)/1000;
    h5=refpropm('h','t',T5+273.15,'q',q5,fluid)/1000;
    
    %punto 6
    h6=h5;
    p6=pint(j);
    T6=refpropm('t','p',p6*100,'h',h6*1000,fluid)-273.15;
    s6=refpropm('s','p',p6*100,'h',h6*1000,fluid)/1000;
    
    %punto 8
    T8=T6;
    p8=p2;
    h8=refpropm('h','t',T8+273.15,'p',p8*100,fluid)/1000;
    s8=refpropm('s','t',T8+273.15,'p',p8*100,fluid)/1000;
    
    %punto 9
    h9=h8;
    p9=p1;
    T9=refpropm('t','p',p9*100,'h',h9*1000,fluid)-273.15;
    s9=refpropm('s','p',p9*100,'h',h9*1000,fluid)/1000;

    %%calcoli sul cop
    
    m4(j)=Qco/(h4(j)-h5);             %portata al punto 4
    ac=1.086; %valori per il rendimento del compressore
    bc=-0.07129;
    betacil=p2/p1;
    etacil=ac*exp(bc*betacil);
    m1c(j)=rho1*CILb*50*betacil;
    m1v(j)=m4(j)*h4(j)/(h2+h3*(h8-h5)/(h6-h7));   %portata in 7
    m41(j)=m1c(j)/m4(j);
    %m7(j)=m4-m1(j);  
    %pint(j)=pint
    %cop(j)=m4*(h4-h5)/(m1(j)*(h2-h1)+m7(j)*(h3-h7));
    
% %     PUNTO 9
% %     FISSO LA TEMPERATURA DEL CONDENSATORE (Tco=60°C) e la PRESSIONE DEL
% %     COMPRESSORE DI ALTA PRESSIONE ([5.58478329336861]bar) corrispoondente più o meno al COP massimonel caso bistaadio. L'indice j che
% %     corrisponde a questi valori è j=24. Quindi mi prendo i valori per
% %     j=24. Entro con questi dati all'interno dell'IF e mi calcolo la cilindrata dei due compressori    
%     if (j==24)&&(T_A==60)
%         j=24;
%         ac=1.086; %valori per il rendimento del compressore
%         bc=-0.07129;
% %     COMPRESSORE ALTA
%         betacil(j)=pint(j)/pev; %la pint(j) si riferisce al suo ultimo valore nelle T_A_vett. Quindi si riferisce sempre ai 60°C.
%         etacil(j)=ac*exp(bc*betacil(j)); %rendimento del compressore volumetrico
%         rho=refpropm('d','p',pint(j)*100,'h',h7*1000,fluid); %densità dell'aria aspirata al punto 7
%         CILa=m7(j)/(rho*etacil(j))*1000   %cilindrata in LITRI
% %     COMPRESSORE BASSA
%         betacil=pco/pev; %la pint(j) si riferisce al suo ultimo valore nelle T_A_vett. Quindi si riferisce sempre ai 60°C.
%         etacil=ac*exp(bc*betacil); %rendimento del compressore volumetrico
%         rho=refpropm('d','p',pint(j)*100,'h',h1*1000,fluid); %densità
%         dell'aria aspirata al punto 1
%         CILb=m1(j)/(rho*etacil)*1000   %cilindrata in LITRI
%     end
    
    
    end %fine ciclo temperatura intermedia j

    %GRAFICO PORTATA DEL COMPRESSORE DI BASSA PRESSIONE vs PRESSIONE
    %INTERNA
    figure(1)
    grid on
    legend_portata_cpbasso=sprintf('Temperatura CO 60 °C');
    plot(pint, m1v,'r',pint,m41,'k');
    legend(legend_portata_cpbasso);
    hold on
    title('r1234yf');
    xlabel('Pressione intermedia [unità di misura]','FontName','Times','FontSize',18,'FontWeight','Bold')
    ylabel('Portata del compressore di bassa pressione','FontName','Times','FontSize',18,'FontWeight','Bold') 
    hold on
    
%     %GRAFICO PORTATA DEL COMPRESSORE DI ALTA PRESSIONE vs PRESSIONE
%     %INTERNA
%     figure(2)
%     grid on
%     legend_portata_cpbasso=sprintf('Temperatura CO 60 °C');
%     plot(pint, m7);
%     legend(legend_portata_cpbasso);
%     hold on
%     title('r1234yf');
%     xlabel('Pressione intermedia [unità di misura]','FontName','Times','FontSize',18,'FontWeight','Bold')
%     ylabel('Portata del compressore di alta pressione','FontName','Times','FontSize',18,'FontWeight','Bold') 
%     hold on
    
