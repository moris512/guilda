classdef Inner_loop_for_RSC < controller_for_converter.empty
    properties
        KI
        KP
        m_min
        m_max
    end
    methods
        
    %%%%%%%%%%%%%%%
    % constructor %
    %%%%%%%%%%%%%%%
        function obj = Inner_loop_for_RSC(varargin)
            obj@controller_for_converter.empty(varargin)
            obj.parameter = {'KI','KP','m_min','m_max'};
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function to get number/name of states or input/output ports %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function nx = get_nx(obj);  nx = 2;  end
        function nu = get_nu(obj);  nu = 2;  end
        function name = get_x_name(obj);    name = {'chi_d','chi_q'};end
        function name = get_port_name(obj); name = {'ud'  ,'uq'  };end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function to define the dynamics %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [dx, mdq] = get_dx_mdq(obj, t, x, Vbus, vdc, Iconverter, Iref, u)
            dx  = obj.KI * (Iref - Iconverter);
            mdq = 2/vdc * ( obj.KP*(Iref - Iconverter) + x + u);
            mdq = max([mdq,obj.m_min*[1;1]], [], 2);
            mdq = min([mdq,obj.m_max*[1;1]], [], 2);
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function to define the dynamics %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function x_st = set_equilibrium(obj, Idq)
            x_st = Idq;
            obj.x_equilibrium = x_st;
        end

    end

end