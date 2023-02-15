classdef Inner_loop_for_GSC < elements.empty_controller_for_converter
    properties
        tau
        L
        R
        m_min
        m_max
    end

    methods
        
    %%%%%%%%%%%%%%%
    % constructor %
    %%%%%%%%%%%%%%%
        function obj = Inner_loop_for_GSC(varargin)
            obj@elements.empty_controller_for_converter(varargin)
            obj.parameter_name = {'tau','L','R','m_min','M_max'};
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
            omega0 = obj.connected_component.omega0;
            dx  = (Iref - Iconverter)/obj.tau;
            mdq = 2/vdc * (Vbus + [0,obj.L;-obj.L,0]*Iconverter -obj.R*x -obj.L/omega0*dx + u);
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