classdef Battery < component_for_farm.base

    methods
        function obj = Battery(varargin)
            obj@component_for_farm.base(varargin);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % パラメータの設定や取得に関わる関数 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set_parameter(obj,parameter)
            obj.parameter_plant     = parameter(:,{'C','L','G','R','gamma'});
            obj.parameter_converter = parameter(:,{'S'});
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % function to get number/name of states or input/output ports %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function nx = get_nx_plant(obj);        nx=2; end
        function nu = get_nu_converter(obj);    nu=1; end
        function name = get_x_name_plant(obj);          name ={'vb','idc'}; end
        function name = get_port_name_converter(obj);   name ={'uS'}; end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % function to define the dynamics %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [dx, I_tobus, V_toDClink, I_toDClink] = get_dx_VI(obj, x, Vbus, vdc, u)
    
            vb     = x(1);
            idc_p  = x(2);
            us     = u(1);

            % back-and-boost converter
            S = parameter{:,'S'};
            vdc_p = max(S+us,0) * vdc;
            idc   = max(S+us,0) * idc_p;

            % Battery
            C = parameter{:,'C'}; 
            L = parameter{:,'L'};
            G = parameter{:,'G'};
            R = parameter{:,'R'};
            dvb    = obj.connected_farm.omega0/C * (  -idc_p - G*vb);
            didc_p = obj.connected_farm.omega0/L * (-R*idc_p +   vb -vdc_p);

            dx = [dvb;didc_p];
            I_tobus = 0;
            V_toDClink = vdc;
            I_toDClink = idc;
        end

        function x_st = set_equilibrium(obj,V,I, vdc_p, idc_p)
            obj.set_nxu;
            x_st = [];
        end
        
    end
end

