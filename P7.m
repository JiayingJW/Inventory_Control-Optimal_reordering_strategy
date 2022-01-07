%problem data
T=10;   %time horizon
beta=0.975; %discount factor
p=250; %selling price
c=170; %per unit purchasing cost
f=200; %fixed purchasing cost
h=5; %per unit holding cost
v=150; %per unit salvage value
n1=20;%n1*p1 in Binomial distribution create the random daily demand
p1=0.7;
M=20; %shelf space capacity

%transition probabilities
%three dimensional matrix
P=zeros(M+1,M+1,M+1); 
for i=0:M
    for a=0:M-i
        for j=0:M
            if j==0
                P(i+1,j+1,a+1)=1-binocdf(i+a-1,n1,p1); 
            elseif j<=i+a
                P(i+1,j+1,a+1)=binopdf(i+a-j,n1,p1); 
            end
        end
    end
end

%reward function
R=zeros(M+1,M+1);
for i=0:M
    for a=0:M-i
        %first calculate expected sales revenue
        revenue=0;
        %units sold = demand, if demand is less than or equal to i+a
        for d=0:i+a
            revenue=revenue+p*d*binopdf(d,n1,p1);
        end
        %units sold = i+a, if demand is more than i+a
        revenue=revenue+p*(i+a)*(1-binocdf(i+a,n1,p1));
        %expected holding cost
        holding=0;
        for d=0:i+a
            holding=holding+h*(i+a-d)*binopdf(d,n1,p1);
        end
        %ordering cost
        if a==0
            ordering=0;
        else
            ordering=f+c*a;
        end
        reward=revenue-holding-ordering;
        R(i+1,a+1)=reward;
    end
end

V=zeros(M+1,T+1);%optimal value functions matrix
pi=zeros(M+1,T);%optimal controls matrix

%final period reward
for i=0:M
    V(i+1,T+1)=v*i;
end

%solve recursively periods T-1,T-2,...,2,1,0
for n=T-1:-1:0 %for n = T-1 down to 0
    for i=0:M
    temp=zeros(M-i+1,1); %storage area for 
    %the value functions associated
    %with all available controls a
        for a=0:M-i
            temp(a+1,1)=R(i+1,a+1)+beta*dot(P(i+1,:,a+1),V(:,n+2));
        end
        %then pick best possible action (ordering quantity)
        [max_value, index] = max(temp);
        V(i+1,n+1)=max_value;
        pi(i+1,n+1)=index-1;
    end
end

V  %display optimal value functions matrix on screen
pi %display optimal controls matrix on screen

%convert pi to a table
table = array2table(pi);
A={'day0'};
for i=1:9
    A=[A, ['day',num2str(i)]];
end
table.Properties.VariableNames=A;
B={'inv_level_0'};
for i=1:20
    B=[B, ['inv_level_',num2str(i)]];
end
table.Properties.RowNames=B

%visualize the optimal controls
figure;
imagesc(pi);  
axis xy
colormap(jet)
colorbar;
set(gca,'XTick',1:T,'YTick',1:M+1,'XGrid','on','YGrid','on');
set(gca,'XTickLabel',0:T-1,'YTickLabel',0:M);
xlabel('$n$ (days)','interpreter','latex','fontSize',24);
ylabel('inventory level $i$','interpreter','latex','fontSize',24);
title('ordering quantity $\pi_n(i)$','fontSize',18,'interpreter','latex','fontWeight','bold');
set(gcf,'color','white');





