classdef GSC_for_wind < component_for_farm.base

    methods
        function obj = GSC_for_wind(varargin)
            obj@component_for_farm.base(varargin);
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % パラメータの設定や取得に関わる関数 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set_parameter(obj,parameter)
            obj.parameter_converter = parameter(:,{'R','L'});
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % function to get number/name of states or input/output ports %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function out = get_nx_converter(obj);       out = 2;           end
        function out = get_x_name_converter(obj);   out = {'Id','Iq'}; end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % function to define the dynamics %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [dx, I_tobus, V_toDClink, I_toDClink] = get_dx_VI(x, Vbus, vdc, u)

            % separate the state/input data
            x_idx  = 1:sum(obj.a_nx);
            x_cidx = cumsum(obj.a_nx);
            u_idx  = 1:sum(obj.a_nu);
            u_cidx = cumsum(obj.a_nu);

            Idq    = x(1:2);
            x_in   = x(x_idx>cidx(2) & x_idx<=x_cidx(3));
            u_in   = u(u_idx>cidx(2) & u_idx<=u_cidx(3));
            x_out  = x(x_idx>cidx(3) & x_idx<=x_cidx(4));
            u_out  = u(u_idx>cidx(3) & u_idx<=u_cidx(4));


            gamma = tools.vcellfun( @(c) c.parameter_plant{:,'gamma'}, obj.connected_farm.component_plant_side);
            PQ = -sum(gamma) * (Vbus(1)+1j*V(2)) * (Idq(1)-1j*Idq(2));
            [dx_out, Iref] = get_dx_Iref(obj, t, x_out, vdc, imag(PQ), u_out);
            [dx_in , mdq ] =  get_dx_mdq(obj, t, x_in , Vbus, vdc, Idq, Iref, u_in);


            R = obj.parameter{:,'R'};
            L = obj.parameter{:,'L'};
            dIdq = [-R, L;-L,-R]*IG + V - mdq/2*vdc; 


            dx = [dIdq; dx_in; dx_out]; 
            I_tobus = Idq;
            V_toDClink = Vbus;
            I_toDClink = Idq;
        end

        function x_st = set_equilibrium(obj,V,I, vdc_p, idc_p)
            obj.set_nxu;
            vdc_st = hoge;  %%%%%編集途中%%%%%%
            Idq = hoge;     %%%%%編集途中%%%%%%
            Qst = V(2)*Idq(1) - V(1)*Idq(1); 
            x_st{1}  = obj.set_equilibrium_part(V,I);
            x_st{2} = obj.Inner_loop_controller.set_equilibrium(V,I);
            x_st{3} = obj.Outer_loop_controller.set_equilibrium(Idq, vdc_st, Qst);
            x_st = vertcat(x_st{:});
        end
        
    end
end

