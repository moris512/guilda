classdef Outer_loop < controller_for_converter.empty
    properties
        KPd
        KPq
        KId
        KIq
    end

    properties(SetAccess = protected)
        udq_st
    end

    properties(Access = private)
        system_matrix = ss(0);
    end

    methods
    %%%%%%%%%%%%%%%
    % constructor %
    %%%%%%%%%%%%%%%
        function obj = Outer_loop(varargin)
            obj@controller_for_converter.empty(varargin)
            obj.parameter = {'KPd','KPq','KId','KIq'};
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function to get number/name of states or input/output ports %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function idx_nonzerosKI = check_KI(obj)
            KI = [obj.KId,obj.KIq];
            idx_nonzerosKI = KI~=0;
        end
        function nx = get_nx(obj)
            nx = sum(obj.check_KI);
        end
        function name = get_x_name(obj)
            name = {'xi_d','xi_q'};
            name = name(obj.check_KI);
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function to define the dynamics %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [dx, Iref] = get_dx_Iref(obj, t, x, ud, uq, u)
            u_   = [ud-obj.ud_st; uq-obj.uq_st];
            dx   = obj.system_matrix.A * x + obj.system_matrix.B * u_;
            Iref = sum([obj.system_matrix.C * x , obj.system_matrix.D * u_],2);
        end

        function x_st = set_equilibrium(obj, Idq, ud_st, uq_st)
            x_st = Idq;
            x_st = x_st(obj.check_KI(:));
            obj.x_equilibrium = x_st;
            obj.udq_st = [ud_st;uq_st];
            obj.initialize();
        end

        function initialize(obj)
            nx = 0;
            B = [];
            C = [];
            if  obj.KId ~= 0
                B = [B;[obj.KId,0]];
                C = [C,[1;0]];
                nx = nx+1;
            end
            
            if obj.KIq ~= 0
                B = [B;[0,obj.KIq]];
                C = [C,[0;1]];
                nx = nx+1;
            end

            A = zeros(nx,nx);
            D = diag([obj.KPd,obj.KPq]);
            obj.system_matrix = ss(A,B,C,D);
        end

        function set_parameter(obj,parameter)
            obj.KPd = parameter{:,'KPd'};
            obj.KPq = parameter{:,'KPq'};
            obj.KId = parameter{:,'KId'};
            obj.KIq = parameter{:,'KIq'};
        end

    end

end