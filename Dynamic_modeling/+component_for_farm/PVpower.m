classdef PVpower < component_for_farm.base

    methods
        function obj = PVpower(varargin)
            obj@component_for_farm.base(varargin);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % パラメータの設定や取得に関わる関数 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set_parameter(obj,parameter)
            obj.parameter_plant     = parameter(:,{'V','R','gamma'});
            obj.parameter_converter = parameter(:,{'S'});
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % function to define the dynamics %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [dx, I_tobus, V_toDClink, I_toDClink] = get_dx_VI(x, Vbus, vdc, u)

            S    = obj.parameter_converter{:,'S'};
            V_PV = obj.parameter_plant{:,'V'};
            R_PV = obj.parameter_plant{:,'R'};

            vdc_p = S * vdc;
            idc_p = (V_PV-vdc_p)/R_PV;
            idc   = S*idc_p;

            dx = [];
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

