classdef SwingEquation_Inference
    properties
        lb
        ub
        x_u
        t_u
        x_f
        t_f
        u
        layers
        nu
        weights
        biases
        sess
        x_u_tf
        t_u_tf
        u_tf
        x_f_tf
        t_f_tf
        u_pred
        f_pred
        loss
        optimizer
    end
    
    methods
        function self = SwingEquation_Inference(X_u, u, X_f, layers, lb, ub)
            self.lb = lb;
            self.ub = ub;
            self.x_u = X_u(:, 1);
            self.t_u = X_u(:, 2);
            self.x_f = X_f(:, 1);
            self.t_f = X_f(:, 2);
            self.u = u;
            self.layers = layers;
            %self.nu = nu;
            
            self.weights = self.initialize_NN(layers);
            self.biases = cell(1, length(layers) - 1);
            self.sess = [];
            
            self.x_u_tf = tf('placeholder', 'float32', 'shape', [NaN, size(self.x_u, 2)]);
            self.t_u_tf = tf('placeholder', 'float32', 'shape', [NaN, size(self.t_u, 2)]);
            self.u_tf = tf('placeholder', 'float32', 'shape', [NaN, size(self.u, 2)]);
            self.x_f_tf = tf('placeholder', 'float32', 'shape', [NaN, size(self.x_f, 2)]);
            self.t_f_tf = tf('placeholder', 'float32', 'shape', [NaN, size(self.t_f, 2)]);
            
            self.u_pred = self.net_u(self.x_u_tf, self.t_u_tf);
            self.f_pred = self.net_f(self.x_f_tf, self.t_f_tf);
            
            self.loss = mean((self.u_tf - self.u_pred).^2) + mean(self.f_pred.^2);
            
            self.optimizer = tf.contrib.opt.ScipyOptimizerInterface(self.loss, 'method', 'L-BFGS-B', ...
                'options', struct('maxiter', 50000, 'maxfun', 50000, 'maxcor', 50, 'maxls', 50, ...
                'gtol', 1e-8, 'eps', 1e-8, 'ftol', 1e-15));
            
            init = tf.global_variables_initializer();
            self.sess = tf.Session('config', tf.ConfigProto('allow_soft_placement', true, 'log_device_placement', true));
            self.sess.run(init);
        end
        
        function weights = initialize_NN(self, layers)
            weights = cell(1, length(layers) - 1);
            for l = 1:length(layers) - 1
                in_dim = layers(l);
                out_dim = layers(l + 1);
                xavier_stddev = sqrt(2/(in_dim + out_dim));
                weights{l} = tf.Variable(tf.truncated_normal([in_dim, out_dim], 'stddev', xavier_stddev), 'dtype', 'float32');
                self.biases{l} = tf.Variable(tf.zeros([1, out_dim], 'dtype', 'float32'), 'dtype', 'float32');
            end
        end
        
        function Y = neural_net(self, X, weights, biases)
            num_layers = length(weights) + 1;
            H = 2*(X - self.lb)./(self.ub - self.lb) - 1;
            for l = 1:num_layers - 2
                W = weights{l};
                b = biases{l};
                H = tf.tanh(tf.matmul(H, W) + b);
            end
            W = weights{num_layers - 1};
            b = biases{num_layers - 1};
            Y = tf.matmul(H, W) + b;
        end

        function u = net_u(self, x, t)
        u = self.neural_net(tf.concat([x, t], 1), self.weights, self.biases);
        end
        
        function f = net_f(self, x, t)%Change the u to self.u
            self.u = self.net_u(x, t);
            u_t = tf.gradients(self.u, t);
            u_tt = tf.gradients(u_t, t);
            f = 0.4*u_tt + 0.15*u_t + 0.2*sin(self.u) - x; %nu being used directly.
        end
    
        function train(self)
            tf_dict = {self.x_u_tf, self.x_u, self.t_u_tf, self.t_u, self.u_tf, self.u, ...
                self.x_f_tf, self.x_f, self.t_f_tf, self.t_f};
            self.optimizer.minimize(self.sess, tf_dict);
        end
    
        function [u_star, f_star] = predict(self, X_star)
            u_star = self.sess.run(self.u_pred, {self.x_u_tf, X_star(:, 1), self.t_u_tf, X_star(:, 2)});
            f_star = self.sess.run(self.f_pred, {self.x_f_tf, X_star(:, 1), self.t_f_tf, X_star(:, 2)});
        end
    end
end
