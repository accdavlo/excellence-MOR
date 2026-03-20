clear
clc
close all


%Two dimensional Allen-Cahn
% Define the spatial and temporal domains 
geom.xL=0; geom.xR=2*pi;
geom.yB=0; geom.yT=pi;

T_end = 1;
PDE.a = 0.01; %diffusion coefficient
PDE.r = 10; %reaction coefficient
PDE.uL = 0.; % Dirichlet boundary values
PDE.uR = 0.; 

geom.Nx = 100;
geom.Ny = 100;
geom.N  = geom.Nx*geom.Ny;
geom.x = linspace(geom.xL, geom.xR, geom.Nx); % Spatial domain
geom.y = linspace(geom.yB, geom.yT, geom.Ny); % Spatial domain
geom.dx = geom.x(2)-geom.x(1);
geom.dy = geom.y(2)-geom.y(1);
[geom.XX,geom.YY] = meshgrid(geom.x,geom.y);
geom.X = reshape(geom.XX,geom.Nx*geom.Ny,1);
geom.Y = reshape(geom.YY,geom.Nx*geom.Ny,1);

Nt = 100;
t = linspace(0, T_end, Nt); % Temporal domain
dt = t(2)-t(1);
u = zeros(length(t),geom.Nx*geom.Ny); % Initialize solution matrix

PDE.jacobian = @(u, ident, D2, dt) ident-PDE.a*dt*D2 + PDE.r*dt* spdiags(3*u.^2-1,0,length(u),length(u));
PDE.residual = @(u,un, ident, D2, dt) u-un-PDE.a*dt*D2*u + PDE.r*dt* (u.^3-u);
%Let's assemble the matrix of the second derivative
% univariate second derivative matrices
ex = ones(geom.Nx,1);
D2x = spdiags([ex,-2*ex,ex],-1:1,geom.Nx,geom.Nx)/geom.dx^2;
Idx = speye(geom.Nx);
ey = ones(geom.Ny,1);
D2y = spdiags([ey,-2*ey,ey],-1:1, geom.Ny,geom.Ny)/geom.dy^2;
Idy = speye(geom.Ny);

D2 = kron(D2x,Idy)+kron(Idx,D2y);

%computing border idxs for BC
idxs_L = (geom.X==geom.xL);
idxs_R = (geom.X==geom.xR);
idxs_B = (geom.Y==geom.yB);
idxs_T = (geom.Y==geom.yT);
geom.idxs_BC = find(logical(idxs_L + idxs_R + idxs_T + idxs_B));

Newton.tol_increment = 1e-10;
Newton.tol_residual  = 1e-10;
Newton.max_iter = 100;



%u(1,:)= rand(length(geom.X),1)*2-1;%
u(1,:) = sin(geom.X).*sin(4*geom.Y);  %
u(1,geom.idxs_BC) =0.;

waitbar0 = waitbar(0,'Running...');
fprintf("");
for it=2:Nt
    u_tmp = u(it-1,:);
    deltaU = u_tmp;
    rhs = u_tmp;
    i_newton=0;
    while(i_newton <= Newton.max_iter && ...
        (norm(deltaU) > norm(u_tmp)*Newton.tol_increment ||...
        norm(rhs)> norm(u_tmp)*Newton.tol_residual))
        i_newton = i_newton +1;
        rhs = PDE.residual(u_tmp', u(it-1,:)', speye(geom.N), D2, dt);
        J = PDE.jacobian(u_tmp', speye(geom.N), D2, dt);

        % apply Dirichlet BC homogeneous
        J(geom.idxs_BC,:)=0;
        J=J+sparse(geom.idxs_BC,geom.idxs_BC,1.,geom.N,geom.N);
        rhs(geom.idxs_BC) = 0;

        deltaU = J \ rhs; % Solve for the update
        u_tmp = u_tmp - deltaU'; % Update the solution
    end
    waitbar(it/Nt,waitbar0);
    %fprintf("\rIt = %03d, norm delta %1.3e",it,norm(deltaU))
    u(it,:) = u_tmp; % Solve the linear system for the next time step
end
waitbar(1,waitbar0,"Complete!");
close(waitbar0);

%Plot the solution
figure()
contourf(geom.XX, geom.YY, reshape(u(100,:),geom.Ny, geom.Nx), 'LineColor','none');
%clim([-1,1]);
title("Final solution")
colorbar()

%Play with initial conditions (try random), diffusion and reaction parameters.

% Create a gif of the 2D solution evolving in time (contourf)
gifFilename = 'allen_Cahn_2d_evolution.gif';
figg = figure('Visible','off');
vmin = min(u(:)); vmax = max(u(:));
for it = 1:4:Nt
    contourf(geom.XX, geom.YY, reshape(u(it,:),geom.Ny, geom.Nx), 20, 'LineColor','none');
   % clim([vmin vmax]);
   caxis([vmin vmax]);
    colorbar;
    title(sprintf('Solution at t = %0.4f', t(it)));
    xlabel('x'); ylabel('y');
    axis tight; daspect([1 1 1]);
    drawnow;
    frame = getframe(figg);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if it == 1
        imwrite(imind,cm,gifFilename,'gif','Loopcount',Inf,'DelayTime',max(0.01,dt));
    else
        imwrite(imind,cm,gifFilename,'gif','WriteMode','append','DelayTime',max(0.01,dt));
    end
end
close(figg);
