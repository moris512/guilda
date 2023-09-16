%%
%nu = 0.2; Used directly in in function f = net_f(self, x, t)
noise = 0;
N_u = 40;
N_f = 8000;
layers = [2, 10, 10, 10, 10, 10, 1];
data = load('/Users/morispolanco/Documents/GitHub/guilda/+moris/Data/swingEquation_inference.mat');
t = data.t(:);
x = data.x(:);
Exact = real(data.usol)';
[X, T] = meshgrid(x, t);
X_star = [X(:), T(:)];
u_star = Exact(:);
lb = [0.08, 0];
ub = [0.18, 20];
xx1 = [X(1, :)', T(1, :)'];
uu1 = Exact(1, :)';
xx2 = [X(:, 1), T(:, 1)];
uu2 = Exact(:, 1);
xx3 = [X(:, end), T(:, end)];
uu3 = Exact(:, end);
X_u_train = [xx1; xx2; xx3];
X_f_train = lb + (ub - lb).*lhsdesign(N_f, 2);
X_f_train = [X_f_train; X_u_train];
u_train = [uu1; uu2; uu3];
idx = randperm(size(X_u_train, 1), N_u);
X_u_train = X_u_train(idx, :);
u_train = u_train(idx, :);

model = SwingEquation_Inference(X_u_train, u_train, X_f_train, layers, lb, ub);
%%
start_time = tic;
model.train();
elapsed = toc(start_time);
fprintf('Training time: %.4f\n', elapsed);

start_time = tic;
[u_pred, f_pred] = model.predict(X_star);
elapsed = toc(start_time);
fprintf('Prediction time: %.4f\n', elapsed);

error_u = norm(u_star - u_pred, 2)/norm(u_star, 2);
fprintf('Error u: %e\n', error_u);

start_time = tic;
[u_pred, f_pred] = model.predict(X_star);
U_pred = griddata(X_star(:, 1), X_star(:, 2), u_pred, X, T, 'cubic');
elapsed = toc(start_time);
fprintf('Prediction time: %.4f\n', elapsed);