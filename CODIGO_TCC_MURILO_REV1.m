% MURILO HENRIQUE SANCHES - RA:791384 - TEL (16) - 992805891
clc 
clear 
close all
rng(1,'twister');

%% =========================================================
% CONFIGURACAO DE SALVAMENTO DE GRAFICOS
% Todos os graficos sao exportados como PDF vetorial para uso no Overleaf.
% =========================================================
dir_graficos = 'C:\Users\Lenovo\Documents\MURILO UFSCAR\TCC\DROP TEST\graficos';
if ~exist(dir_graficos, 'dir')
    mkdir(dir_graficos);
end
salva_pdf = @(fh, dir, nome) exportgraphics( ...
    fh, fullfile(dir,[nome '.pdf']), ...
    'ContentType','vector', ...
    'BackgroundColor','white');


%% VALORES DOS ELEMENTOS DO SISTEMA
k_f = 10600; % Rigidez da mola dianteira [N/m]
k_r = 12000; % Rigidez da mola traseira [N/m]
B_f = 400; % Amortecimento do amortecedor dianteiro [Ns/m]
B_r = 400; % Amortecimento do amortecedor traseiro [Ns/m]

m_nsf = 13.5; % Massa nao suspensa dianteira (independente) [Kg]
m_nsr = 10.0; % Massa nao suspensa traseira (independente) [Kg]

%% definindo as Rigidez e amortecimento dos pneus

pressao = [7 14 21 28 35];
nP = length(pressao);
% Rigidez dos pneus: direcao (traseiro) e tracao (dianteiro)
rig_p1 = [53.4048*1000,   73.8972*1000,   91.3968*1000,  110.2447*1000,  119.3237*1000];   % [N/m] - pneu de direcao
rig_p2 = [56.7490*1000,   86.3609*1000,  111.9129*1000,  134.2906*1000,  150.4083*1000];   % [N/m] - dianteiro

amort_p1 = [34.62482948, 33.94912285, 32.61179326, 30.56064406, 27.5192764]; %[N.s/m]
amort_p2 = [40.99092234, 38.35331187, 36.91272917, 35.26975838, 34.19564178]; %[N.s/m]

m_fr = 72.85; % massa eixo dianteiro direito [kg]
m_fl = 72.55; % massa eixo dianteiro esquerdo [kg]
m_rr = 77.3;  % massa eixo traseiro direito [kg]
m_rl = 71.60; % massa eixo traseiro esquerdo [kg]

%% Posicao do CG

EE=1.46; % entre eixos [m]
M = m_fr+m_fl+m_rr+m_rl; %MASSA TOTAL [kg]
M_s = M-(2*m_nsf +2*m_nsr); %Kg - massa suspensa do carro sem piloto
bt_f = 1.32; %Bitola dianteira [m]
bt_r = 1.26; %Bitola traseira [m]

k_pitch = 0.55;   % fator do raio de giracao de pitch [-]
k_roll  = 0.40;   % fator do raio de giracao de roll  [-]
I_x = M_s*(k_pitch*EE)^2;  % Momento de inercia de arfagem (pitch) [kg*m^2]
I_z = M_s*(k_roll*bt_r)^2; % Momento de inercia de rolagem (roll)  [kg*m^2]
M_R_elev = 77.1+81.25; %massa eixo traseiro levantando o dianteiro [kg];
M_f = m_fr+m_fl; %massa eixo dianteiro [kg]
M_r = m_rr+m_rl; %massa eixo traseiro [kg]

del_r_bt = (bt_f-bt_r)/2; % distancia entre linhas de controle de bitola [m]
l_r = (M_f*EE)/M; % distancia do eixo traseiro para o CG [m]
l_f =   EE-l_r; %distancia do eixo dianteiro para o CG [m]
y_linha = ((m_fl/M)*(bt_f-del_r_bt))-((m_fr/M)*del_r_bt) + ((m_rl*bt_r)/M); % distancia do cg ao eixo logitudinal que cortar as rodas do carro visto de cima [m]
y_linhalinha = y_linha-(bt_r/2); % distancia do CG a linha longitudinal que divide o carro no eixo de simetria visto de cima
dx = y_linhalinha*(-1);  % deslocamento lateral do CG (positivo para a esquerda)

d_fr = (bt_f/2)-dx;
d_fl = ((bt_f/2)+ dx);
d_rr = (bt_r/2)-dx;
d_rl =((bt_r/2)+dx);

%% entrada degrau + rampa
velo_deg = 15; % [km/h] velocidade no ensaio de degrau
v_deg = velo_deg/3.6; % [m/s] velocidade no ensaio de degrau
dtotal = 30; % Distancia de analise [m]
%calculo do atraso da roda traseira;
atraso = (l_f+l_r)/v_deg; 
%tempo do percurso e vetor tempo;
tfim_deg = (dtotal/v_deg)+10;
tini_deg = 0;
ts_deg = 0.001;
t_deg=tini_deg:ts_deg:tfim_deg; 
d_deg = t_deg*v_deg;

%% Parametros da faixa elevada
h_faixa = 0.4;        % altura da faixa elevada [m]
d_ini   = 10;          % posicao inicial da rampa de subida [m]

L_subida  = 1;       % comprimento da rampa de subida [m]
L_plano   = 2;       % comprimento da parte plano [m]
L_descida = 1;       % comprimento da rampa de descida [m]

% comprimento total da faixa
L_total = L_subida + L_plano + L_descida;

%% Perfil espacial da faixa para o eixo dianteiro
uf = zeros(size(d_deg));

% coordenada local da faixa
xi = d_deg - d_ini;

% rampa de subida
idx_subida = xi >= 0 & xi < L_subida;
uf(idx_subida) = h_faixa * xi(idx_subida)/L_subida;

% parte plana
idx_plano = xi >= L_subida & xi < (L_subida + L_plano);
uf(idx_plano) = h_faixa;

% rampa de descida
idx_descida = xi >= (L_subida + L_plano) & xi <= L_total;
uf(idx_descida) = h_faixa * ...
    (1 - (xi(idx_descida) - L_subida - L_plano)/L_descida);

%% Perfil para o eixo traseiro
EE = l_f + l_r;

xi_r = d_deg - d_ini - EE;
ur = zeros(size(d_deg));

% rampa de subida traseira
idx_subida_r = xi_r >= 0 & xi_r < L_subida;
ur(idx_subida_r) = h_faixa * xi_r(idx_subida_r)/L_subida;

% parte plana traseira
idx_plano_r = xi_r >= L_subida & xi_r < (L_subida + L_plano);
ur(idx_plano_r) = h_faixa;

% rampa de descida traseira
idx_descida_r = xi_r >= (L_subida + L_plano) & xi_r <= L_total;
ur(idx_descida_r) = h_faixa * ...
    (1 - (xi_r(idx_descida_r) - L_subida - L_plano)/L_descida);

%% Entradas para as quatro rodas
y1 = uf;   % dianteira direita
y2 = uf;   % dianteira esquerda
y3 = ur;   % traseira direita
y4 = ur;   % traseira esquerda


%% PLOT DO PERFIL DE PISTA - DIANTEIRA E TRASEIRA
figure; clf;
hold on

plot(d_deg, uf, 'k-',  'LineWidth', 1.5, 'DisplayName', 'Eixo Dianteiro');
plot(d_deg, ur, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Eixo Traseiro');

hold off
grid on
box on

xlabel('Distância [m]')
ylabel('Deslocamento [m]')
title('Perfil de Pista — Faixa Elevada')
legend('Location', 'northeast')
xlim([0 30])
ylim([-0.05 0.50])

set(gca,'FontName','Times','FontWeight','bold','FontSize',10)

salva_pdf(gcf, dir_graficos, 'fig_perfil_pista_espacial');



%% Entrada Drop
g = 9.81;            % gravidade [m/s^2]
h = 0.25;            % queda de 250 mm
tini_drop = 0;
ts_drop = 0.001;
tfim_drop = 5;

% Força o vetor a ser uma coluna (N x 1)
t_drop_teo = (tini_drop:ts_drop:tfim_drop)'; 

% Tempo real da queda 
Tqueda = sqrt(2*h/g);

% Instantes de inicio e fim do evento 
t0 = 0;                 % inicio da queda
t_f = t0 + Tqueda;      % fim da queda fisica 

% Inicializa vetor de deslocamento com o mesmo tamanho exato
u_drop = zeros(size(t_drop_teo));

% Fase 1 -- antes da queda
u_drop(t_drop_teo < t0) = 0;

% Fase 2 -- queda 
mask = (t_drop_teo >= t0) & (t_drop_teo <= t_f);
t_queda = t_drop_teo(mask) - t0;
u_drop(mask) = -0.5 * g * (t_queda.^2);  

% Fase 3 -- final constante (-h = -0.25 m)
u_drop(t_drop_teo > t_f) = -h;

% PLOT DO PERFIL DO DROP TEST
figure; clf;
hold on

plot(t_drop_teo, u_drop, 'k-', 'LineWidth', 1.5, 'DisplayName', 'Trajetória');

hold off
grid on
box on


xlabel('Tempo [s]')
ylabel('Deslocamento [m]')
legend('Location', 'northeast')
xlim([0 1]);
ylim([-0.3 0.1]);

set(gca, 'FontName', 'Times', 'FontWeight', 'bold', 'FontSize', 10)

salva_pdf(gcf, dir_graficos, 'fig_perfil_droptest');

%% GERACAO DE PERFIL DE PISTA ISO 8608 - CLASSE F

rng(1,'twister');   % garante reprodutibilidade

% Parametros da ISO 8608
Gd0 = 16384e-6;     % [m^3] valor medio geometrico correto da classe F
n0  = 0.1;          % [ciclos/m] frequencia espacial de referencia
psd_exp = 2;        % expoente da PSD ISO 8608 

n_min = 0.01;       % [ciclos/m] comprimento de onda maximo = 100 m
n_max = 10;         % [ciclos/m] comprimento de onda minimo = 0,1 m

L = 3000;           % [m] comprimento da pista
dx_iso = 0.01;      % [m] resolucao espacial

x = 0:dx_iso:(L-dx_iso);
nISO = length(x);
L_eff = nISO*dx_iso;

fs_x = 1/dx_iso;        % [amostras/m]
dn = 1/L_eff;           % [ciclos/m]

kpos = 2:floor(nISO/2);
N = (kpos-1)*dn;

idx = (N >= n_min) & (N <= n_max);
n_sel = N(idx);
k_sel = kpos(idx);

Gd = Gd0*(n_sel/n0).^(-psd_exp);

Z = zeros(1,nISO);
phi = 2*pi*rand(size(n_sel));
mag = sqrt(nISO*Gd/(2*dx_iso));

Z(k_sel) = mag .* exp(1i*phi);

k_conj = nISO - k_sel + 2;
Z(k_conj) = conj(Z(k_sel));

z = real(ifft(Z));
z = z - mean(z);

z_l = z;
z_r = z_l;

%% CONVERSAO ESPACIAL -> TEMPORAL

v_iso = 15;                 % [m/s]
fs_iso = v_iso/dx_iso;      % [Hz]
t_perfil = (0:nISO-1)/fs_iso;

atraso_iso = (l_f + l_r)/v_iso;
N_delay = round(atraso_iso*fs_iso);

y_fl_perfil = z_l;
y_fr_perfil = z_r;

y_rl_perfil = [zeros(1,N_delay), y_fl_perfil(1:end-N_delay)];
y_rr_perfil = [zeros(1,N_delay), y_fr_perfil(1:end-N_delay)];

u_fd = y_fr_perfil(:);   % dianteira direita
u_fe = y_fl_perfil(:);   % dianteira esquerda
u_td = y_rr_perfil(:);   % traseira direita
u_te = y_rl_perfil(:);   % traseira esquerda

%% PLOT DA PISTA

figure;
plot(x, z_l, 'b'); hold on;
plot(x, z_r, 'r');
grid on;
xlabel('Distancia [m]');
ylabel('Deslocamento [m]');
title('Perfil de pista ISO 8608 Classe F');
legend('Esquerda','Direita');
set(gca,'FontName','Times','FontWeight','bold','FontSize',10)
salva_pdf(gcf, dir_graficos, 'fig01_perfil_pista_espacial');

%% PLOT TEMPORAL

figure;
plot(t_perfil, y_fl_perfil, 'k'); hold on;
plot(t_perfil, y_rl_perfil, '--r');
grid on;
xlabel('Tempo [s]');
ylabel('Deslocamento [m]');
legend('Dianteira','Traseira');
set(gca,'FontName','Times','FontWeight','bold','FontSize',10)
salva_pdf(gcf, dir_graficos, 'fig02_perfil_pista_temporal');

%% Pre-alocar matrizes de resultados
nISO = length(t_perfil);

% CG
Zoc_ifd_iso = zeros(nISO, nP);
Zoc_ife_iso = zeros(nISO, nP);
Zoc_itd_iso = zeros(nISO, nP);
Zoc_ite_iso = zeros(nISO, nP);
Zoc_iso     = zeros(nISO, nP);

% frente direita
Zofd_ifd_iso = zeros(nISO, nP);
Zofd_ife_iso = zeros(nISO, nP);
Zofd_itd_iso = zeros(nISO, nP);
Zofd_ite_iso = zeros(nISO, nP);
Zofd_iso     = zeros(nISO, nP);

% frente esquerda
Zofe_ifd_iso = zeros(nISO, nP);
Zofe_ife_iso = zeros(nISO, nP);
Zofe_itd_iso = zeros(nISO, nP);
Zofe_ite_iso = zeros(nISO, nP);
Zofe_iso     = zeros(nISO, nP);

% traseira direita
Zotd_ifd_iso = zeros(nISO, nP);
Zotd_ife_iso = zeros(nISO, nP);
Zotd_itd_iso = zeros(nISO, nP);
Zotd_ite_iso = zeros(nISO, nP);
Zotd_iso     = zeros(nISO, nP);

% traseira esquerda
Zote_ifd_iso = zeros(nISO, nP);
Zote_ife_iso = zeros(nISO, nP);
Zote_itd_iso = zeros(nISO, nP);
Zote_ite_iso = zeros(nISO, nP);
Zote_iso     = zeros(nISO, nP);

% roll
Alpha_ifd_iso = zeros(nISO, nP);
Alpha_ife_iso = zeros(nISO, nP);
Alpha_itd_iso = zeros(nISO, nP);
Alpha_ite_iso = zeros(nISO, nP);
Alpha_iso     = zeros(nISO, nP);

% pitch
Beta_ifd_iso = zeros(nISO, nP);
Beta_ife_iso = zeros(nISO, nP);
Beta_itd_iso = zeros(nISO, nP);
Beta_ite_iso = zeros(nISO, nP);
Beta_iso     = zeros(nISO, nP);

% CG
Zoc_ifd_D = zeros(length(t_deg), nP);
Zoc_ife_D = zeros(length(t_deg), nP);
Zoc_itd_D   = zeros(length(t_deg), nP);
Zoc_ite_D   = zeros(length(t_deg), nP);
Zoc_D  = zeros(length(t_deg), nP);

% frontal direita
Zofd_ifd_D = zeros(length(t_deg), nP);
Zofd_ife_D = zeros(length(t_deg), nP);
Zofd_itd_D  = zeros(length(t_deg), nP);
Zofd_ite_D   = zeros(length(t_deg), nP);
Zofd_D  = zeros(length(t_deg), nP);

% frontal esquerda
Zofe_ifd_D = zeros(length(t_deg), nP);
Zofe_ife_D = zeros(length(t_deg), nP);
Zofe_itd_D  = zeros(length(t_deg), nP);
Zofe_ite_D   = zeros(length(t_deg), nP);
Zofe_D  = zeros(length(t_deg), nP);

% traseira direita
Zotd_ifd_D = zeros(length(t_deg), nP);
Zotd_ife_D = zeros(length(t_deg), nP);
Zotd_itd_D  = zeros(length(t_deg), nP);
Zotd_ite_D   = zeros(length(t_deg), nP);
Zotd_D  = zeros(length(t_deg), nP);

% traseira esquerda
Zote_ifd_D = zeros(length(t_deg), nP);
Zote_ife_D = zeros(length(t_deg), nP);
Zote_itd_D  = zeros(length(t_deg), nP);
Zote_ite_D   = zeros(length(t_deg), nP);
Zote_D  = zeros(length(t_deg), nP);

% roll
Alpha_ifd_D = zeros(length(t_deg), nP);
Alpha_ife_D = zeros(length(t_deg), nP);
Alpha_itd_D = zeros(length(t_deg), nP);
Alpha_ite_D = zeros(length(t_deg), nP);
Alpha_D = zeros(length(t_deg), nP);

% pitch
Beta_ifd_D = zeros(length(t_deg), nP);
Beta_ife_D = zeros(length(t_deg), nP);
Beta_itd_D = zeros(length(t_deg), nP);
Beta_ite_D = zeros(length(t_deg), nP);
Beta_D = zeros(length(t_deg), nP);

% drop test
Zoc_ifd_drop = zeros(length(t_drop_teo), nP);
Zoc_ife_drop = zeros(length(t_drop_teo), nP);
Zoc_itd_drop = zeros(length(t_drop_teo), nP);
Zoc_ite_drop = zeros(length(t_drop_teo), nP);
Zoc_drop = zeros(length(t_drop_teo), nP);

Zofd_ifd_drop = zeros(length(t_drop_teo), nP);
Zofd_ife_drop = zeros(length(t_drop_teo), nP);
Zofd_itd_drop = zeros(length(t_drop_teo), nP);
Zofd_ite_drop = zeros(length(t_drop_teo), nP);
Zofd_drop = zeros(length(t_drop_teo), nP);

Zofe_ifd_drop = zeros(length(t_drop_teo), nP);
Zofe_ife_drop = zeros(length(t_drop_teo), nP);
Zofe_itd_drop = zeros(length(t_drop_teo), nP);
Zofe_ite_drop = zeros(length(t_drop_teo), nP);
Zofe_drop = zeros(length(t_drop_teo), nP);

Zotd_ifd_drop = zeros(length(t_drop_teo), nP);
Zotd_ife_drop = zeros(length(t_drop_teo), nP);
Zotd_itd_drop = zeros(length(t_drop_teo), nP);
Zotd_ite_drop = zeros(length(t_drop_teo), nP);
Zotd_drop = zeros(length(t_drop_teo), nP);

Zote_ifd_drop = zeros(length(t_drop_teo), nP);
Zote_ife_drop = zeros(length(t_drop_teo), nP);
Zote_itd_drop = zeros(length(t_drop_teo), nP);
Zote_ite_drop = zeros(length(t_drop_teo), nP);
Zote_drop = zeros(length(t_drop_teo), nP);

%% Montando as matrizes
G_7dof = cell(1, nP);  % armazena G completo por pressao para reuso
for i = 1:nP

    k_tf = rig_p2(i);      % dianteiro (tracao)
    k_tr = rig_p1(i);      % traseiro (direcao)
    B_tf = amort_p2(i);    % dianteiro
    B_tr = amort_p1(i);    % traseiro
    
    s = tf('s');
    A = tf(zeros(7,7));

    % Vertical roda FD (Zofd)
    A(1,1) = ((m_nsf)*s^2 + (B_f+B_tf)*s + k_f + k_tf);
    A(1,5) = -((B_f)*s + (k_f));
    A(1,6) = (B_f*d_fl)*s + (k_f*d_fl);
    A(1,7) = (B_f*l_f)*s + (k_f*l_f);

    % Vertical roda FE (Zofe)
    A(2,2) = (m_nsf)*s^2 + (B_f+B_tf)*s + k_f + k_tf;
    A(2,5) = -((B_f)*s + (k_f));
    A(2,6) = -((B_f*d_fr)*s + (k_f*d_fr)); 
    A(2,7) = (B_f*l_f)*s + (k_f*l_f);

    % Vertical roda TD (Zotd)
    A(3,3) = (m_nsr)*s^2 + (B_r+B_tr)*s + k_r + k_tr;
    A(3,5) = -((B_r)*s + (k_r));
    A(3,6) = ((B_r*d_rl)*s + (k_r*d_rl));
    A(3,7) = -((B_r*l_r)*s + (k_r*l_r));

    % Vertical roda TE (Zote)
    A(4,4) = (m_nsr)*s^2 + (B_r+B_tr)*s + k_r + k_tr;
    A(4,5) = -((B_r)*s + (k_r));
    A(4,6) = -((B_r*d_rr)*s + (k_r*d_rr)); 
    A(4,7) = -((B_r*l_r)*s + (k_r*l_r));

    % Vertical chassi (Zoc)
    A(5,1) = -((B_f)*s + (k_f));
    A(5,2) = -((B_f)*s + (k_f));
    A(5,3) = -((B_r)*s + (k_r));
    A(5,4) = -((B_r)*s + (k_r));
    A(5,5) = ((M_s)*s^2 + (2*B_f+2*B_r)*s + (2*k_f+2*k_r));
    A(5,6) = ((d_fl-d_fr)*B_f +(d_rl-d_rr)*B_r)*s + ((d_fl-d_fr)*k_f + (d_rl-d_rr)*k_r);
    A(5,7) = 2*((l_f*B_f-l_r*B_r)*s+(l_f*k_f-l_r*k_r));

    % Angulo Roll (Alpha)
    A(6,1) = -((B_f*d_fl)*s + (k_f*d_fl));
    A(6,2) = ((B_f*d_fr)*s + (k_f*d_fr));
    A(6,3) = -((B_r*d_rl)*s + (k_r*d_rl));
    A(6,4) = ((B_r*d_rr)*s + (k_r*d_rr));
    A(6,5) = -(((d_fr-d_fl)*B_f +(d_rr-d_rl)*B_r)*s +((d_fr-d_fl)*k_f + (d_rr-d_rl)*k_r));
    A(6,6) = (I_z)*s^2 + (B_f*d_fl^2 + B_r*d_rl^2 + B_f*d_fr^2 + B_r*d_rr^2)*s + (k_f*d_fl^2 + k_r*d_rl^2 + k_f*d_fr^2 + k_r*d_rr^2);
    A(6,7) = -((d_fr-d_fl)*B_f*l_f - B_r*l_r*(d_rr-d_rl))*s + ((d_fr-d_fl)*(k_f*l_f) - (d_rr-d_rl)*k_r*l_r);

    % Angulo Pitch (Beta)
    A(7,1) = -((B_f*l_f)*s + (k_f*l_f));
    A(7,2) = -((B_f*l_f)*s + (k_f*l_f));
    A(7,3) = ((B_r*l_r)*s + (k_r*l_r));
    A(7,4) = ((B_r*l_r)*s + (k_r*l_r));
    A(7,5) = ((2*l_f*B_f-2*l_r*B_r)*s+(2*l_f*k_f-2*l_r*k_r));
    A(7,6) = -((d_fl-d_fr)*B_f*l_f - B_r*l_r*(d_rl-d_rr))*s + ((d_fl-d_fr)*(k_f*l_f) - (d_rl-d_rr)*k_r*l_r);
    A(7,7) = (I_x)*s^2 + (2*B_f*l_f^2 + 2*B_r*l_r^2)*s + (2*k_f*l_f^2 + 2*k_r*l_r^2);

    Bbase = tf(zeros(7,4));
    Bbase(1,1) = B_tf*s + k_tf;
    Bbase(2,2) = B_tf*s + k_tf;
    Bbase(3,3) = B_tr*s + k_tr;
    Bbase(4,4) = B_tr*s + k_tr;

    G = inv(A) * Bbase;
    G_7dof{i} = G;

    zofd_ifd = G(1,1); zofe_ifd = G(2,1); zotd_ifd = G(3,1); zote_ifd = G(4,1); zoc_ifd = G(5,1); alpha_ifd = G(6,1); beta_ifd = G(7,1);
    zofd_ife = G(1,2); zofe_ife = G(2,2); zotd_ife = G(3,2); zote_ife = G(4,2); zoc_ife = G(5,2); alpha_ife = G(6,2); beta_ife = G(7,2);
    zofd_itd = G(1,3); zofe_itd = G(2,3); zotd_itd = G(3,3); zote_itd = G(4,3); zoc_itd = G(5,3); alpha_itd = G(6,3); beta_itd = G(7,3);
    zofd_ite = G(1,4); zofe_ite = G(2,4); zotd_ite = G(3,4); zote_ite = G(4,4); zoc_ite = G(5,4); alpha_ite = G(6,4); beta_ite = G(7,4);
    
    % ISO 
    Zoc_ifd_iso(:,i) = lsim(zoc_ifd, u_fd, t_perfil);
    Zoc_ife_iso(:,i) = lsim(zoc_ife, u_fe, t_perfil);
    Zoc_itd_iso(:,i) = lsim(zoc_itd, u_td, t_perfil);
    Zoc_ite_iso(:,i) = lsim(zoc_ite, u_te, t_perfil);
    Zoc_iso(:,i) = Zoc_ifd_iso(:,i) + Zoc_ife_iso(:,i) + Zoc_itd_iso(:,i) + Zoc_ite_iso(:,i);

    Zofd_ifd_iso(:,i) = lsim(zofd_ifd, u_fd, t_perfil);
    Zofd_ife_iso(:,i) = lsim(zofd_ife, u_fe, t_perfil);
    Zofd_itd_iso(:,i) = lsim(zofd_itd, u_td, t_perfil);
    Zofd_ite_iso(:,i) = lsim(zofd_ite, u_te, t_perfil);
    Zofd_iso(:,i) = Zofd_ifd_iso(:,i) + Zofd_ife_iso(:,i) + Zofd_itd_iso(:,i) + Zofd_ite_iso(:,i);

    Zofe_ifd_iso(:,i) = lsim(zofe_ifd, u_fd, t_perfil);
    Zofe_ife_iso(:,i) = lsim(zofe_ife, u_fe, t_perfil);
    Zofe_itd_iso(:,i) = lsim(zofe_itd, u_td, t_perfil);
    Zofe_ite_iso(:,i) = lsim(zofe_ite, u_te, t_perfil);
    Zofe_iso(:,i) = Zofe_ifd_iso(:,i) + Zofe_ife_iso(:,i) + Zofe_itd_iso(:,i) + Zofe_ite_iso(:,i);

    Zotd_ifd_iso(:,i) = lsim(zotd_ifd, u_fd, t_perfil);
    Zotd_ife_iso(:,i) = lsim(zotd_ife, u_fe, t_perfil);
    Zotd_itd_iso(:,i) = lsim(zotd_itd, u_td, t_perfil);
    Zotd_ite_iso(:,i) = lsim(zotd_ite, u_te, t_perfil);
    Zotd_iso(:,i) = Zotd_ifd_iso(:,i) + Zotd_ife_iso(:,i) + Zotd_itd_iso(:,i) + Zotd_ite_iso(:,i);

    Zote_ifd_iso(:,i) = lsim(zote_ifd, u_fd, t_perfil);
    Zote_ife_iso(:,i) = lsim(zote_ife, u_fe, t_perfil);
    Zote_itd_iso(:,i) = lsim(zote_itd, u_td, t_perfil);
    Zote_ite_iso(:,i) = lsim(zote_ite, u_te, t_perfil);
    Zote_iso(:,i) = Zote_ifd_iso(:,i) + Zote_ife_iso(:,i) + Zote_itd_iso(:,i) + Zote_ite_iso(:,i);

    Alpha_ifd_iso(:,i) = lsim(alpha_ifd, u_fd, t_perfil);
    Alpha_ife_iso(:,i) = lsim(alpha_ife, u_fe, t_perfil);
    Alpha_itd_iso(:,i) = lsim(alpha_itd, u_td, t_perfil);
    Alpha_ite_iso(:,i) = lsim(alpha_ite, u_te, t_perfil);
    Alpha_iso(:,i) = Alpha_ifd_iso(:,i) + Alpha_ife_iso(:,i) + Alpha_itd_iso(:,i) + Alpha_ite_iso(:,i);

    Beta_ifd_iso(:,i) = lsim(beta_ifd, u_fd, t_perfil);
    Beta_ife_iso(:,i) = lsim(beta_ife, u_fe, t_perfil);
    Beta_itd_iso(:,i) = lsim(beta_itd, u_td, t_perfil);
    Beta_ite_iso(:,i) = lsim(beta_ite, u_te, t_perfil);
    Beta_iso(:,i) = Beta_ifd_iso(:,i) + Beta_ife_iso(:,i) + Beta_itd_iso(:,i) + Beta_ite_iso(:,i);

    % Degrau
    Zoc_ifd_D(:,i) = lsim(zoc_ifd,y1,t_deg);
    Zoc_ife_D(:,i)= lsim(zoc_ife,y2,t_deg);
    Zoc_itd_D(:,i) = lsim(zoc_itd,y3,t_deg);
    Zoc_ite_D(:,i) = lsim(zoc_ite,y4,t_deg);
    Zoc_D(:,i) = Zoc_ifd_D(:,i) + Zoc_ife_D(:,i) + Zoc_itd_D(:,i) + Zoc_ite_D(:,i);

    Zofd_ifd_D(:,i) = lsim(zofd_ifd,y1,t_deg);
    Zofd_ife_D(:,i) = lsim(zofd_ife,y2,t_deg);
    Zofd_itd_D(:,i) = lsim(zofd_itd,y3,t_deg);
    Zofd_ite_D(:,i) = lsim(zofd_ite,y4,t_deg);
    Zofd_D(:,i) = Zofd_ifd_D(:,i) + Zofd_ife_D(:,i) + Zofd_itd_D(:,i) + Zofd_ite_D(:,i);

    Zofe_ifd_D(:,i) = lsim(zofe_ifd,y1,t_deg);
    Zofe_ife_D(:,i) = lsim(zofe_ife,y2,t_deg);
    Zofe_itd_D(:,i) = lsim(zofe_itd,y3,t_deg);
    Zofe_ite_D(:,i) = lsim(zofe_ite,y4,t_deg);
    Zofe_D(:,i) = (Zofe_ifd_D(:,i) + Zofe_ife_D(:,i) + Zofe_itd_D(:,i) + Zofe_ite_D(:,i));

    Zotd_ifd_D(:,i) = lsim(zotd_ifd,y1,t_deg);
    Zotd_ife_D(:,i) = lsim(zotd_ife,y2,t_deg);
    Zotd_itd_D(:,i) = lsim(zotd_itd,y3,t_deg);
    Zotd_ite_D(:,i) = lsim(zotd_ite,y4,t_deg);
    Zotd_D(:,i) = (Zotd_ifd_D(:,i) + Zotd_ife_D(:,i) + Zotd_itd_D(:,i) + Zotd_ite_D(:,i));

    Zote_ifd_D(:,i) = lsim(zote_ifd,y1,t_deg);
    Zote_ife_D(:,i) = lsim(zote_ife,y2,t_deg);
    Zote_itd_D(:,i) = lsim(zote_itd,y3,t_deg);
    Zote_ite_D(:,i) = lsim(zote_ite,y4,t_deg);
    Zote_D(:,i) = (Zote_ifd_D(:,i) + Zote_ife_D(:,i) + Zote_itd_D(:,i) + Zote_ite_D(:,i));

    Alpha_ifd_D(:,i) = lsim(alpha_ifd,y1,t_deg);
    Alpha_ife_D(:,i) = lsim(alpha_ife,y2,t_deg);
    Alpha_itd_D(:,i) = lsim(alpha_itd,y3,t_deg);
    Alpha_ite_D(:,i) = lsim(alpha_ite,y4,t_deg);
    Alpha_D(:,i) = (Alpha_ifd_D(:,i) + Alpha_ife_D(:,i) + Alpha_itd_D(:,i) + Alpha_ite_D(:,i));

    Beta_ifd_D(:,i) = lsim(beta_ifd,y1,t_deg);
    Beta_ife_D(:,i) = lsim(beta_ife,y2,t_deg);
    Beta_itd_D(:,i) = lsim(beta_itd,y3,t_deg);
    Beta_ite_D(:,i) = lsim(beta_ite,y4,t_deg);
    Beta_D(:,i) = (Beta_ifd_D(:,i) + Beta_ife_D(:,i) + Beta_itd_D(:,i) + Beta_ite_D(:,i));
    
    % DROP 
    Zoc_ifd_drop(:,i) = lsim(zoc_ifd,u_drop,t_drop_teo);
    Zoc_ife_drop(:,i)= lsim(zoc_ife,u_drop,t_drop_teo);
    Zoc_itd_drop(:,i) = lsim(zoc_itd,u_drop,t_drop_teo);
    Zoc_ite_drop(:,i) = lsim(zoc_ite,u_drop,t_drop_teo);
    Zoc_drop(:,i) = Zoc_ifd_drop(:,i) + Zoc_ife_drop(:,i) + Zoc_itd_drop(:,i) + Zoc_ite_drop(:,i);

    Zofd_ifd_drop(:,i) = lsim(zofd_ifd,u_drop,t_drop_teo);
    Zofd_ife_drop(:,i)= lsim(zofd_ife,u_drop,t_drop_teo);
    Zofd_itd_drop(:,i) = lsim(zofd_itd,u_drop,t_drop_teo);
    Zofd_ite_drop(:,i) = lsim(zofd_ite,u_drop,t_drop_teo);
    Zofd_drop(:,i) = Zofd_ifd_drop(:,i) + Zofd_ife_drop(:,i) + Zofd_itd_drop(:,i) + Zofd_ite_drop(:,i);

    Zofe_ifd_drop(:,i) = lsim(zofe_ifd,u_drop,t_drop_teo);
    Zofe_ife_drop(:,i)= lsim(zofe_ife,u_drop,t_drop_teo);
    Zofe_itd_drop(:,i) = lsim(zofe_itd,u_drop,t_drop_teo);
    Zofe_ite_drop(:,i) = lsim(zofe_ite,u_drop,t_drop_teo);
    Zofe_drop(:,i) = Zofe_ifd_drop(:,i) + Zofe_ife_drop(:,i) + Zofe_itd_drop(:,i) + Zofe_ite_drop(:,i);

    Zotd_ifd_drop(:,i) = lsim(zotd_ifd,u_drop,t_drop_teo);
    Zotd_ife_drop(:,i)= lsim(zotd_ife,u_drop,t_drop_teo);
    Zotd_itd_drop(:,i) = lsim(zotd_itd,u_drop,t_drop_teo);
    Zotd_ite_drop(:,i) = lsim(zotd_ite,u_drop,t_drop_teo);
    Zotd_drop(:,i) = Zotd_ifd_drop(:,i) + Zotd_ife_drop(:,i) + Zotd_itd_drop(:,i) + Zotd_ite_drop(:,i);

    Zote_ifd_drop(:,i) = lsim(zote_ifd,u_drop,t_drop_teo);
    Zote_ife_drop(:,i)= lsim(zote_ife,u_drop,t_drop_teo);
    Zote_itd_drop(:,i) = lsim(zote_itd,u_drop,t_drop_teo);
    Zote_ite_drop(:,i) = lsim(zote_ite,u_drop,t_drop_teo);
    Zote_drop(:,i) = Zote_ifd_drop(:,i) + Zote_ife_drop(:,i) + Zote_itd_drop(:,i) + Zote_ite_drop(:,i);
end


%% PLOTS DEGRAUS COM SUBPLOTS DE ZOOM

figure(3); clf;
cores = lines(nP);

subplot(2,3,[1,3])
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2, 'DisplayName', 'Entrada (degrau)');

for i = 1:nP
    plot(t_deg, Zoc_D(:,i), 'Color', cores(i,:), 'LineWidth', 1, ...
        'DisplayName', sprintf('%d psi', pressao(i)));
end
hold off; grid on; box on;
title('CG - Todas as Pressões - 15 km/h')
xlabel('Tempo [s]')
ylabel('Amplitude [m]')
xlim([0 10])
ylim([-0.1 0.5])
legend('Location','east')
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

xline(3.0, '--k', 'HandleVisibility', 'off');
xline(4.3, '--k', 'HandleVisibility', 'off');

% Zoom 1
subplot(2,3,4)
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2);
for i = 1:nP
    plot(t_deg, Zoc_D(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim([3.0 3.35]); ylim([0.25 0.5]);
ylabel('Amplitude [m]'); xlabel('Tempo [s]'); title('Zoom - Pico 1');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

% Zoom 2
subplot(2,3,5)
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2);
for i = 1:nP
    plot(t_deg, Zoc_D(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim([3.35 4.05]); ylim([-0.08 0.18]);
xlabel('Tempo [s]'); title('Zoom - Pico 2');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

% Zoom 3
subplot(2,3,6)
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2);
for i = 1:nP
    plot(t_deg, Zoc_D(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim([3.3 5.2]); ylim([-0.08 0.06]);
xlabel('Tempo [s]'); title('Zoom - Pico 3');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

salva_pdf(gcf, dir_graficos, 'fig03_cg_degrau');

%% RODA DIANTEIRA DIREITA - Degrau - Todas as Pressões - 15 km/h

figure(4); clf;
subplot(2,3,[1,3])
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2, 'DisplayName', 'Entrada (degrau)');

for i = 1:nP
    plot(t_deg, Zofd_D(:,i), 'Color', cores(i,:), 'LineWidth', 1, ...
        'DisplayName', sprintf('%d psi', pressao(i)));
end
hold off; grid on; box on;
title('Roda Dianteira direita - Todas as Pressões - 15 km/h')
xlabel('Tempo [s]'); ylabel('Amplitude [m]'); xlim([0 10]); ylim([-0.1 0.5]);
legend('Location','east')
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

xline(2.3, '--k', 'HandleVisibility', 'off');
xline(4.3, '--k', 'HandleVisibility', 'off');

subplot(2,3,4)
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2);
for i = 1:nP
    plot(t_deg, Zofd_D(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim([2.3 3.0]); ylim([0.25 0.5]); ylabel('Amplitude [m]'); xlabel('Tempo [s]'); title('Zoom - Pico 1');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

subplot(2,3,5)
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2);
for i = 1:nP
    plot(t_deg, Zofd_D(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim([3.0 3.35]); ylim([0.25 0.45]); xlabel('Tempo [s]'); title('Zoom - Pico 2');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

subplot(2,3,6)
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2);
for i = 1:nP
    plot(t_deg, Zofd_D(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim([3.2 5.2]); ylim([-0.04 0.08]); xlabel('Tempo [s]'); title('Zoom - Pico 3');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

salva_pdf(gcf, dir_graficos, 'fig04_roda_dianteira_degrau');

%% RODA TRASEIRA DIREITA - Degrau - Todas as Pressões - 15 km/h

figure(5); clf;
subplot(2,3,[1,3])
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2, 'DisplayName', 'Entrada (degrau)');

for i = 1:nP
    plot(t_deg, Zotd_D(:,i), 'Color', cores(i,:), 'LineWidth', 1, ...
        'DisplayName', sprintf('%d psi', pressao(i)));
end
hold off; grid on; box on;
title('Roda Traseira Direita - Todas as Pressões - 15 km/h')
xlabel('Tempo [s]'); ylabel('Amplitude [m]'); xlim([0 10]); ylim([-0.1 0.5]);
legend('Location','east')
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

xline(2.1, '--k', 'HandleVisibility', 'off');
xline(4.3, '--k', 'HandleVisibility', 'off');

subplot(2,3,4)
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2);
for i = 1:nP
    plot(t_deg, Zotd_D(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim([2.4 2.8]); ylim([0.0 0.1]); ylabel('Amplitude [m]'); xlabel('Tempo [s]'); title('Zoom - Pico 1');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

subplot(2,3,5)
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2);
for i = 1:nP
    plot(t_deg, Zotd_D(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim([2.8 3.8]); ylim([0.3 0.42]); xlabel('Tempo [s]'); title('Zoom - Pico 2');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

subplot(2,3,6)
hold on
plot(t_deg, uf, 'k', 'LineWidth', 2);
for i = 1:nP
    plot(t_deg, Zotd_D(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim([3.6 5.2]); ylim([-0.03 0.03]); xlabel('Tempo [s]'); title('Zoom - Pico 3');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

salva_pdf(gcf, dir_graficos, 'fig05_roda_traseira_degrau');


%% ACELERACAO DO CASO ISO 8608
ts_iso = t_perfil(2) - t_perfil(1);
fs_iso = 1/ts_iso;

fc_iso_lp = 80;
[biso, aiso] = butter(4, fc_iso_lp/(fs_iso/2));

fc_iso_hp = 0.5;
[bhp, ahp] = butter(4, fc_iso_hp/(fs_iso/2), 'high');

for i = 1:nP
    zfd_lp = filtfilt(biso, aiso, Zofd_iso(:,i));
    ztd_lp = filtfilt(biso, aiso, Zotd_iso(:,i));
    zcg_lp = filtfilt(biso, aiso, Zoc_iso(:,i));

    zfd_f = filtfilt(bhp, ahp, zfd_lp);
    ztd_f = filtfilt(bhp, ahp, ztd_lp);
    zcg_f = filtfilt(bhp, ahp, zcg_lp);

    A_fd_iso_g(:,i)   = diff2_central(zfd_f, ts_iso) / 9.81;
    A_td_iso_g(:,i)   = diff2_central(ztd_f, ts_iso) / 9.81;
    A_cg_iso_g(:,i)   = diff2_central(zcg_f, ts_iso) / 9.81;
    A_fd_iso_ms2(:,i) = diff2_central(zfd_f, ts_iso);
    A_td_iso_ms2(:,i) = diff2_central(ztd_f, ts_iso);
    A_cg_iso_ms2(:,i) = diff2_central(zcg_f, ts_iso);
end


%% Metricas para comparacao entre pressoes (MANTIDO pois serve de apoio para os graficos)
met_iso = table(pressao(:), 'VariableNames', {'pressao_psi'});
met_iso.aCG_pico_g = zeros(nP,1);
met_iso.aCG_rms_g  = zeros(nP,1);
met_iso.fdomCG_Hz  = zeros(nP,1);

met_iso.aFD_pico_g = zeros(nP,1);
met_iso.aFD_rms_g  = zeros(nP,1);

met_iso.aTD_pico_g = zeros(nP,1);
met_iso.aTD_rms_g  = zeros(nP,1);

for i = 1:nP
    acg = detrend(A_cg_iso_g(:,i));
    afd = detrend(A_fd_iso_g(:,i));
    atd = detrend(A_td_iso_g(:,i));

    met_iso.aCG_pico_g(i) = max(abs(acg));
    met_iso.aCG_rms_g(i)  = rms(acg);

    [Pxx_cg, f_cg] = pwelch(acg, hamming(2048), 1024, 2048, fs_iso);
    [~, idx] = max(Pxx_cg);
    met_iso.fdomCG_Hz(i) = f_cg(idx);

    met_iso.aFD_pico_g(i) = max(abs(afd));
    met_iso.aFD_rms_g(i)  = rms(afd);

    met_iso.aTD_pico_g(i) = max(abs(atd));
    met_iso.aTD_rms_g(i)  = rms(atd);
end


%% 2) Deslocamento do CG para cada pressao
figure; hold on; grid on;
for i = 1:nP
    plot(t_perfil, Zoc_iso(:,i), 'LineWidth', 1.2, ...
        'DisplayName', sprintf('%d psi', pressao(i)));
end
xlabel('Tempo [s]');
ylabel('Deslocamento do CG [m]');
legend('Location', 'eastoutside')
salva_pdf(gcf, dir_graficos, 'fig08_iso_deslocamento_cg');


%% ZOOM FIXO ISO 8608 - ACELERAÇÃO DO CG

figure; clf;
x_zoom = [100.2 100.6];
y_zoom = [-0.1 2.1];

subplot(2,3,[1,3])
hold on
for i = 1:nP
    plot(t_perfil, A_cg_iso_g(:,i), 'Color', cores(i,:), 'LineWidth', 1, ...
        'DisplayName', sprintf('%d psi', pressao(i)));
end
hold off; grid on; box on;
xlabel('Tempo [s]'); ylabel('Aceleração vertical do CG [g]');
legend('Location', 'eastoutside')
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

xline(x_zoom(1), '--k', 'HandleVisibility', 'off');
xline(x_zoom(2), '--k', 'HandleVisibility', 'off');

subplot(2,3,[4,6])
hold on
for i = 1:nP
    plot(t_perfil, A_cg_iso_g(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim(x_zoom); ylim(y_zoom);
xlabel('Tempo [s]'); ylabel('Aceleração vertical do CG [g]'); title('Zoom - Faixa selecionada');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

salva_pdf(gcf, dir_graficos, 'fig09_iso_aceleracao_cg_zoom');


%% ZOOM FIXO ISO 8608 - ACELERAÇÃO DA RODA DIANTEIRA DIREITA

figure; clf;
cores = lines(nP);
x_zoom = [100.2 100.6];
y_zoom = [4 45];

subplot(2,3,[1,3])
hold on
for i = 1:nP
    plot(t_perfil, A_fd_iso_g(:,i), 'Color', cores(i,:), 'LineWidth', 1, ...
        'DisplayName', sprintf('%d psi', pressao(i)));
end
hold off; grid on; box on;
xlabel('Tempo [s]'); ylabel('a_{FD} [g]');
legend('Location', 'eastoutside')
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

xline(x_zoom(1), '--k', 'HandleVisibility', 'off');
xline(x_zoom(2), '--k', 'HandleVisibility', 'off');

subplot(2,3,[4,6])
hold on
for i = 1:nP
    plot(t_perfil, A_fd_iso_g(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim(x_zoom); ylim(y_zoom);
xlabel('Tempo [s]'); ylabel('a_{FD} [g]'); title('Zoom - Faixa selecionada');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

salva_pdf(gcf, dir_graficos, 'fig10a_iso_roda_dianteira_aceleracao_zoom');


%% ZOOM FIXO ISO 8608 - ACELERAÇÃO DA RODA TRASEIRA DIREITA

figure; clf;
x_zoom = [100.2 100.6];
y_zoom = [4 45];

subplot(2,3,[1,3])
hold on
for i = 1:nP
    plot(t_perfil, A_td_iso_g(:,i), 'Color', cores(i,:), 'LineWidth', 1, ...
        'DisplayName', sprintf('%d psi', pressao(i)));
end
hold off; grid on; box on;
xlabel('Tempo [s]'); ylabel('a_{TD} [g]');
legend('Location', 'eastoutside')
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

xline(x_zoom(1), '--k', 'HandleVisibility', 'off');
xline(x_zoom(2), '--k', 'HandleVisibility', 'off');

subplot(2,3,[4,6])
hold on
for i = 1:nP
    plot(t_perfil, A_td_iso_g(:,i), 'Color', cores(i,:), 'LineWidth', 0.8);
end
hold off; grid on; box on;
xlim(x_zoom); ylim(y_zoom);
xlabel('Tempo [s]'); ylabel('a_{TD} [g]'); title('Zoom - Faixa selecionada');
set(gca,'FontName','Times','FontWeight','bold','FontSize',8)

salva_pdf(gcf, dir_graficos, 'fig10b_iso_roda_traseira_aceleracao_zoom');


%% 5) Barras de comparacao - CG
figure;

subplot(3,1,1);
bar(pressao, met_iso.aCG_pico_g);
grid on; ylabel('Pico [g]'); title('CG - Pico de aceleracao');

subplot(3,1,2);
bar(pressao, met_iso.aCG_rms_g);
grid on; ylabel('RMS [g]'); title('CG - Aceleracao RMS');

subplot(3,1,3);
bar(pressao, met_iso.fdomCG_Hz);
grid on; xlabel('Pressao [psi]'); ylabel('f_{dom} [Hz]'); title('CG - Frequencia dominante');

salva_pdf(gcf, dir_graficos, 'fig11_iso_barras_cg');

%% 6) PSD da aceleracao do CG

figure; hold on; grid on;
for i = 1:nP
    [Pxx_cg, f_cg] = pwelch(detrend(A_cg_iso_g(:,i)), ...
        hamming(4096), 2048, 4096, fs_iso);
    plot(f_cg, 10*log10(Pxx_cg), 'LineWidth', 1.4, ...
        'DisplayName', sprintf('%d psi', pressao(i)));
end
xlim([0 80]);
xlabel('Frequencia [Hz]');
ylabel('PSD [dB(m/s^2)^2/Hz]');
legend('Location','northeast');
grid minor;
set(gca,'FontName','Times','FontWeight','bold','FontSize',10)
salva_pdf(gcf, dir_graficos, 'fig12_iso_psd_aceleracao');

%% 7) Comparacao FD x TD
figure;

subplot(2,1,1);
bar(pressao, [met_iso.aFD_pico_g met_iso.aTD_pico_g]);
grid on; ylabel('Pico [g]'); title('Rodas - Pico de aceleracao');
legend('FD','TD','Location','best');

subplot(2,1,2);
bar(pressao, [met_iso.aFD_rms_g met_iso.aTD_rms_g]);
grid on; xlabel('Pressao [psi]'); ylabel('RMS [g]'); title('Rodas - Aceleracao RMS');
legend('FD','TD','Location','best');
salva_pdf(gcf, dir_graficos, 'fig13_iso_comparacao_fd_td');


%% ==============================================
%   ACELERACAO DO DROP TEST (MODELO 7GDL)
% ===============================================

ts_drop = t_drop_teo(2) - t_drop_teo(1);

A_cg_drop  = zeros(size(Zoc_drop));
A_fd_drop  = zeros(size(Zofd_drop));
A_fe_drop  = zeros(size(Zofe_drop));
A_td_drop  = zeros(size(Zotd_drop));
A_te_drop  = zeros(size(Zote_drop));

for i = 1:nP
    A_cg_drop(:,i) = diff2_central(Zoc_drop(:,i), ts_drop);
    A_fd_drop(:,i) = diff2_central(Zofd_drop(:,i), ts_drop);
    A_fe_drop(:,i) = diff2_central(Zofe_drop(:,i), ts_drop);
    A_td_drop(:,i) = diff2_central(Zotd_drop(:,i), ts_drop);
    A_te_drop(:,i) = diff2_central(Zote_drop(:,i), ts_drop);
end 

%% TESTE EXPERIMENTAL - DROP TEST

fs_exp = 3200;      % frequencia de amostragem experimental
fc_exp_lp = 100;    % frequencia de corte do filtro experimental/teorico [Hz]
[b_exp,a_exp] = butter(4, fc_exp_lp/(fs_exp/2));

fs_teo = 1/ts_drop;
[b_teo,a_teo] = butter(4, fc_exp_lp/(fs_teo/2));

A_cg_drop_cmp = A_cg_drop / 9.81;
A_fd_drop_cmp = A_fd_drop / 9.81;
A_fe_drop_cmp = A_fe_drop / 9.81;
A_td_drop_cmp = A_td_drop / 9.81;
A_te_drop_cmp = A_te_drop / 9.81;

for i = 1:nP
    A_cg_drop_cmp(:,i) = filtfilt(b_teo,a_teo,A_cg_drop_cmp(:,i));
    A_fd_drop_cmp(:,i) = filtfilt(b_teo,a_teo,A_fd_drop_cmp(:,i));
    A_fe_drop_cmp(:,i) = filtfilt(b_teo,a_teo,A_fe_drop_cmp(:,i));
    A_td_drop_cmp(:,i) = filtfilt(b_teo,a_teo,A_td_drop_cmp(:,i));
    A_te_drop_cmp(:,i) = filtfilt(b_teo,a_teo,A_te_drop_cmp(:,i));
end

arquivos = {
     'test_7psi.lvm' , 7;
     'test_14psi.lvm', 14;
     'test_21psi.lvm', 21;
     'test_28psi.lvm', 28;
     'test_35psi.lvm', 35; 
};

N_drop = size(arquivos,1);

dados = struct('pressao', [], ...
               't', [], ...
               'cg_raw', [], 'rear_raw', [], 'front_raw', [], ...
               'cg_filt', [], 'rear_filt', [], 'front_filt', []);

g0 = 1;
limiar = 0.5*g0;

for k = 1:N_drop
    nome = arquivos{k,1};
    press = arquivos{k,2};
    
    raw = importdata(nome, '\t', 24);
    raw = raw.data(:,2:4);

    a_cg_raw    = raw(:,1);
    a_rear_raw  = raw(:,2);
    a_front_raw = raw(:,3);

    t_drop = (0:(length(a_cg_raw)-1))/fs_exp;

    a_cg_f    = filtfilt(b_exp,a_exp,a_cg_raw);
    a_rear_f  = filtfilt(b_exp,a_exp,a_rear_raw);
    a_front_f = filtfilt(b_exp,a_exp,a_front_raw);

    idx_ini = find(abs(a_cg_f) > limiar, 1, 'first');

    if isempty(idx_ini)
        idx_ini = 1;
    end

    t_drop_cut = t_drop(idx_ini:end) - t_drop(idx_ini);

    a_cg_cut    = a_cg_f(idx_ini:end);
    a_rear_cut  = a_rear_f(idx_ini:end);
    a_front_cut = a_front_f(idx_ini:end);

    dados(k).pressao    = press;
    dados(k).cg_raw     = a_cg_raw;
    dados(k).rear_raw   = a_rear_raw;
    dados(k).front_raw  = a_front_raw;

    dados(k).t_drop     = t_drop_cut;
    dados(k).cg_filt    = a_cg_cut;
    dados(k).rear_filt  = a_rear_cut;
    dados(k).front_filt = a_front_cut;
end

%% ===== COMPARACAO DROP TEST: TEORICO x EXPERIMENTAL =====
Tpeak = 0.60;
for k = 1:N_drop

    press = dados(k).pressao;
    ip = find(pressao == press, 1);
    if isempty(ip)
        continue;
    end

    tE  = dados(k).t_drop(:);
    cgE = dados(k).cg_filt(:);
    fdE = dados(k).front_filt(:);
    tdE = dados(k).rear_filt(:);

    cgT_grid = A_cg_drop_cmp(:,ip);
    fdT_grid = A_fd_drop_cmp(:,ip);
    tdT_grid = A_td_drop_cmp(:,ip);

    fdT0 = interp1(t_drop_teo(:), fdT_grid, tE, 'linear', NaN);

    mask_cc = (tE <= Tpeak) & ~isnan(fdT0) & ~isnan(fdE);
    dt_align = 0;

    if sum(mask_cc) > 20
        sig_e = fdE(mask_cc);
        sig_t = fdT0(mask_cc);
        sig_e = sig_e - mean(sig_e);
        sig_t = sig_t - mean(sig_t);

        fs_e   = 1 / (tE(2) - tE(1));
        max_lag = round(0.20 * fs_e);
        [xc, lags] = xcorr(sig_e, sig_t, max_lag);
        [~, ilag]  = max(xc);
        dt_align   = lags(ilag) / fs_e;

        dt_align = max(min(dt_align, 0.20), -0.20);
    end

    cgT = interp1(t_drop_teo(:), cgT_grid, tE - dt_align, 'linear', NaN);
    fdT = interp1(t_drop_teo(:), fdT_grid, tE - dt_align, 'linear', NaN);
    tdT = interp1(t_drop_teo(:), tdT_grid, tE - dt_align, 'linear', NaN);

    figure;
    subplot(3,1,1); hold on; grid on;
    title(sprintf('%d psi - CG', press));
    plot(tE, cgT, 'b', 'LineWidth', 1.8, 'DisplayName', 'Teórico');
    plot(tE, cgE, 'r', 'LineWidth', 1.2, 'DisplayName', 'Experimental');
    xlabel('Tempo [s]'); ylabel('a_{cg} [g]');
    legend('Location','NE'); xlim([0 1.5]); ylim([-5 5]);

    subplot(3,1,2); hold on; grid on;
    title('Dianteira Direita (FD)');
    plot(tE, fdT, 'b', 'LineWidth', 1.8);
    plot(tE, fdE, 'r', 'LineWidth', 1.2);
    ylabel('a_{fd} [g]');
    xlim([0 1.5]); ylim([-20 20]);

    subplot(3,1,3); hold on; grid on;
    title('Traseira Direita (TD)');
    plot(tE, tdT, 'b', 'LineWidth', 1.8);
    plot(tE, tdE, 'r', 'LineWidth', 1.2);
    ylabel('a_{td} [g]'); xlabel('Tempo [s]');
    xlim([0 1.5]); ylim([-20 20]);
    salva_pdf(gcf, dir_graficos, sprintf('fig15_drop_teo_exp_%dpsi', press));
end

%% =========================================================
% ANALISE DE CONFORTO EM FREQUENCIA - ISO 2631/78 (eixo z)
% ==========================================================

ts_iso = t_perfil(2) - t_perfil(1);
fs_iso = 1/ts_iso;

fc = [1 1.25 1.6 2 2.5 3.15 4 5 6.3 8 10 12.5 16 20 25 31.5 40 50 63 80];
f1 = fc / (2^(1/6));
f2 = fc * (2^(1/6));

lim_fadiga = [
    0.280 0.425 0.63  1.06  1.40  2.36  3.55  4.25  5.60;
    0.250 0.375 0.56  0.95  1.26  2.12  3.15  3.75  5.00;
    0.224 0.335 0.50  0.85  1.12  1.90  2.80  3.35  4.50;
    0.200 0.300 0.45  0.75  1.00  1.70  2.50  3.00  4.00;
    0.180 0.265 0.40  0.67  0.90  1.50  2.24  2.65  3.55;
    0.160 0.235 0.355 0.60  0.80  1.32  2.00  2.35  3.15;
    0.140 0.212 0.315 0.53  0.71  1.18  1.80  2.12  2.80;
    0.140 0.212 0.315 0.53  0.71  1.18  1.80  2.12  2.80;
    0.140 0.212 0.315 0.53  0.71  1.18  1.80  2.12  2.80;
    0.140 0.212 0.315 0.53  0.71  1.18  1.80  2.12  2.80;
    0.180 0.265 0.40  0.67  0.90  1.50  2.24  2.65  3.55;
    0.224 0.335 0.50  0.85  1.12  1.90  2.80  3.35  4.50;
    0.280 0.425 0.63  1.06  1.40  2.36  3.55  4.25  5.60;
    0.355 0.530 0.80  1.32  1.80  3.00  4.50  5.30  7.10;  
    0.450 0.670 1.00  1.70  2.24  3.75  5.60  6.70  9.00;
    0.560 0.850 1.25  2.12  2.80  4.75  7.10  8.50  11.2;
    0.710 1.060 1.60  2.65  3.55  6.00  9.00  10.6  14.0;  
    0.900 1.320 2.00  3.35  4.50  7.50  11.2  13.2  18.0;  
    1.120 1.700 2.50  4.25  5.60  9.50  14.0  17.0  22.4;
    1.400 2.120 3.15  5.30  7.10  11.8  18.0  21.2  28.0;  
];

limites = lim_fadiga;
tempos_txt = {'24 h','16 h','8 h','4 h','2.5 h','1 h','25 min','16 min','1 min'};

rms_bandas = zeros(length(fc), nP);
tempo_admissivel = strings(1,nP);

for ip = 1:nP

    a = A_cg_iso_ms2(:,ip);
    a = a(:);
    a = detrend(a, 0);

    nfft = 16384;
    noverlap = round(nfft/2);
    [Pxx, f] = pwelch(a, hamming(nfft), noverlap, nfft, fs_iso);

    for k = 1:length(fc)
        idx = (f >= f1(k)) & (f < f2(k));
        if sum(idx) < 2
            rms_bandas(k,ip) = 0;
        else
            rms_bandas(k,ip) = sqrt(trapz(f(idx), Pxx(idx)));
        end
    end

    idx_ok = [];
    for jt = 1:size(limites,2)
        if all(rms_bandas(:,ip) <= limites(:,jt))
            idx_ok = jt;
            break;
        end
    end

    if isempty(idx_ok)
        tempo_admissivel(ip) = "< 1 min";
    else
        tempo_admissivel(ip) = tempos_txt{idx_ok};
    end
end

%% Grafico por pressao - ISO 2631

for ip = 1:nP

    figure; hold on; grid on;
    x = 1:length(fc);

    y_floor = 0.016;
    rms_plot = max(rms_bandas(:,ip), y_floor);

    bar(x, rms_plot, 0.75);

    plot(x, limites(:,1), '--', 'LineWidth', 1.2);
    plot(x, limites(:,2), '--', 'LineWidth', 1.2);
    plot(x, limites(:,3), '--', 'LineWidth', 1.2);
    plot(x, limites(:,4), '--', 'LineWidth', 1.2);
    plot(x, limites(:,5), '--', 'LineWidth', 1.2);
    plot(x, limites(:,6), '--', 'LineWidth', 1.2);
    plot(x, limites(:,7), '--', 'LineWidth', 1.2);
    plot(x, limites(:,8), '--', 'LineWidth', 1.2);
    plot(x, limites(:,9), '--', 'LineWidth', 1.2);

    xlim([0.5 length(fc)+0.5]);
    xticks(x);
    xticklabels(string(fc));

    xlabel('Frequencia central da banda de 1/3 de oitava [Hz]');
    ylabel('Aceleracao RMS [m/s^2]');
    title(sprintf('ISO 2631/78 - %d psi', pressao(ip)), 'FontSize', 8);

    legend('RMS por banda','24 h','16 h','8 h','4 h','2.5 h','1 h','25 min','16 min','1 min', ...
        'Location','eastoutside');

    set(gca, 'YScale', 'log');
    ylim([0.016 25]);

    yticks([0.016 0.025 0.04 0.063 0.1 0.16 0.25 0.4 0.63 1 1.6 2.5 4 6.3 10 16 25]);
    yticklabels({'0.016','0.025','0.04','0.063','0.1','0.16','0.25','0.4','0.63','1.0','1.6','2.5','4.0','6.3','10','16','25'});

    ax = gca;
    ax.YMinorGrid = 'on';
    ax.XMinorGrid = 'on';
    ax.Layer = 'top';

    text(length(fc)*0.72, 0.03, ...
        sprintf('Tempo admissivel: %s', tempo_admissivel(ip)), ...
        'FontSize', 9, 'BackgroundColor', 'w', 'EdgeColor', 'k');
    salva_pdf(gcf, dir_graficos, sprintf('fig16_iso2631_bandas_%dpsi', pressao(ip)));
end


%% =========================================================
% ANALISE COMPARATIVA MULTI-CLASSE E MULTI-VELOCIDADE
% Metodo: 7GDL completo no dominio da frequencia
% =========================================================

classes_nome = {'C',    'D',     'E',     'F'    };
Gd0_classes  = [256e-6, 1024e-6, 4096e-6, 16384e-6];
n_cls = length(classes_nome);

vel_kmh   = [10, 21, 32, 43, 54];
vel_ms    = vel_kmh / 3.6;
n_vel     = length(vel_ms);

f_eval = linspace(1, 80, 500);
w_eval = 2*pi*f_eval;

fc_mc = fc;   f1_mc = f1;   f2_mc = f2;
n_bands = length(fc_mc);
lim_mc = lim_fadiga;

H_fd_arr = zeros(nP, length(f_eval), 'like', 1+1j);
H_td_arr = zeros(nP, length(f_eval), 'like', 1+1j);

for ip = 1:nP
    G_ip = G_7dof{ip};
    H_fd = squeeze(freqresp(G_ip(5,1) + G_ip(5,2), w_eval));
    H_td = squeeze(freqresp(G_ip(5,3) + G_ip(5,4), w_eval));
    H_fd_arr(ip,:) = H_fd(:).' .* (-w_eval);
    H_td_arr(ip,:) = H_td(:).' .* (-w_eval);
    H_fd_arr(ip,:) = H_fd_arr(ip,:) .* (-w_eval);
    H_td_arr(ip,:) = H_td_arr(ip,:) .* (-w_eval);
end

idx_mc = zeros(n_cls, n_vel, nP);

for ic = 1:n_cls
    Gd0_mc = Gd0_classes(ic);

    for iv = 1:n_vel
        v_mc = vel_ms(iv);
        t_atraso_mc = (l_f + l_r) / v_mc;

        n_road = max(min(f_eval / v_mc, n_max), n_min);
        Gd_t_eval = Gd0_mc * (n_road / n0).^(-psd_exp) / v_mc;

        for ip = 1:nP
            phase_delay = exp(-1j * w_eval * t_atraso_mc);
            H_total = H_fd_arr(ip,:) + H_td_arr(ip,:) .* phase_delay;

            PSD_cg = abs(H_total).^2 .* Gd_t_eval;

            rms_b = zeros(n_bands, 1);
            for kb = 1:n_bands
                mask = (f_eval >= f1_mc(kb)) & (f_eval < f2_mc(kb));
                if sum(mask) >= 2
                    rms_b(kb) = sqrt(trapz(f_eval(mask), PSD_cg(mask)));
                end
            end

            idx_ok = 0;
            for jt = 1:size(lim_mc, 2)
                if all(rms_b <= lim_mc(:, jt))
                    idx_ok = jt;  break;
                end
            end
            idx_mc(ic, iv, ip) = idx_ok;
        end
    end
end

escala_mc = zeros(n_cls, n_vel, nP);
for ic = 1:n_cls
    for iv = 1:n_vel
        for ip = 1:nP
            v = idx_mc(ic, iv, ip);
            escala_mc(ic, iv, ip) = (v == 0)*0 + (v > 0)*(10 - v);
        end
    end
end

%% Grafico: tempo admissivel vs pressao (Multi-classe)

cores_cls = lines(n_cls);
figura_A = figure('Name','Conforto 7GDL: Classe x Velocidade x Pressao', ...
    'Position',[30 30 1400 500]);

for iv = 1:n_vel
    subplot(1, n_vel, iv);
    hold on; grid on; box on;

    for ic = 1:n_cls
        escala_plot = squeeze(escala_mc(ic, iv, :));
        plot(pressao, escala_plot, '-o', ...
            'Color', cores_cls(ic,:), 'LineWidth', 2, 'MarkerSize', 7, ...
            'DisplayName', ['Classe ' classes_nome{ic}]);
    end

    yticks(0:9);
    yticklabels({'<1min','1min','16min','25min','1h','2.5h','4h','8h','16h','24h'});
    ylim([-0.5 9.5]);
    xlabel('Pressao [psi]');
    if iv == 1
        ylabel('Tempo admissivel');
        legend('Location','northwest','FontSize',8);
    end
    title(sprintf('%d km/h', vel_kmh(iv)));
    xticks(pressao);
end
salva_pdf(figura_A, dir_graficos, 'fig17_multiclasse_tempo_admissivel');


%% FUNCOES AUXILIARES

function a = diff2_central(y, ts)
    % Segunda derivada por diferenca central
    a = zeros(size(y));
    a(2:end-1) = (y(3:end) - 2*y(2:end-1) + y(1:end-2)) / ts^2;
end