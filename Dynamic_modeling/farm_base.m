classdef farm_base< component
    
    properties(SetAccess = protected)
        % classインスタンスのcell配列として格納
        component_grid_side
        component_plant_side
    end

    properties(Dependent)
        parameter
    end

    properties(Access = private)
        a_nx
        a_nu
    end

    properties
        omega0
        parameter_DClink % Cdc, Gsw, RG
    end

    methods

    %%%%%%%%%%%%%%%
    % constructor %
    %%%%%%%%%%%%%%%

        function obj = farm_base(omega0)
            obj.omega0 = omega0;
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function to get number/name of states or input/output ports %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function out = get_para(obj,para)
            out_GS = obj.component_grid_side.(para);
            out_PS = tools.hcellfun(@(c) c.(para), obj.component_plant_side);
            out = [out_GS, out_PS];
        end
        function out = get_a_nx(obj);       out = [1,obj.get_para('get_nx')];                       end
        function out = get_a_nu(obj);       out = [0,obj.get_para('get_nu')];                       end
        function out = get_nx(obj);         out = sum(obj.get_a_nx);                                end
        function out = get_nu(obj);         out = sum(obj.get_a_nu);                                end
        function out = get_x_name(obj);     out = [{'vdc'},obj.get_para('get_x_name')];             end
        function out = get_port_name(obj);  out = obj.get_para('get_port_name');                    end
        function out = get.parameter(obj);  out = [obj.parameter_DClink,obj.get_para('parameter')]; end
        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function to set elements %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function set_component_grid_side(obj,c)
            c.set_id('_GS');
            obj.component_grid_side   = c;  
        end
        function set_component_plant_side(obj,c)
            idx = 1+numel(obj.component_plant_side);
            c.set_id(['_PS',num2str(idx)]);
            obj.component_plant_side{idx} = c; 
        end
        function remove_component_plant_side(obj,idx)
            obj.component_plant_side{idx} = [];
            arrayfun( ...
                @(idx) obj.component_plant_side{idx}.set_id(['_PS',num2str(idx)]), ...
                1:numel(obj.component_plant_side) )
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % function to define the dynamics %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function [dx, con] = get_dx_constraint(obj, t, x, V, I, u)
        % 基本的にgrid_sideの構成要素に関わる変数には'GS'を、plant_sideの構成機器に関わる変数には'PS'をつけている

        % separate the state/input data

            x_idx  = 1:sum(obj.a_nx);
            x_cidx = cumsum(obj.a_nx);

            u_idx  = 1:sum(obj.a_nu);
            u_cidx = cumsum(obj.a_nu);
    
            vdc    = x(1);
            x_GS   = x(x_idx>cidx(1) & x_idx<=x_cidx(2));
            u_GS   = u(u_idx>cidx(1) & u_idx<=u_cidx(2));
                    

        % define the dynamics
    
            % dynamics of "component_plant_side"
            n_source  = numel(obj.a_plant);
            dx_PS     = cell(n_source,1);
            I_PS2bus  = zeros(2,n_source);
            power_sent_to_DClink = zeros(n_source+1,1);
            

            for i = 1:n_source
                x_PSi = x(x_idx>cidx(i+1) & x_idx<=x_cidx(i+2));
                u_PSi = u(u_idx>cidx(i+1) & u_idx<=u_cidx(i+2));
                [dx_PS{i}, I_PS2bus(:,i), V_PSi2DClink, I_PSi2DClink] = obj.component_plant_side{i}.get_dx_VI(x_PSi,V, vdc, u_PSi);
                power_sent_to_DClink(i) = V_PSi2DClink.' * I_PSi2DClink;
            end

            % dynamics of "component_grid_side"
            [dx_GS, I_GS2bus, V_GS2DClink, I_GS2DClink] = obj.component_grid_side.get_dx_VI(x_GS,V, vdc, u_GS);
            power_sent_to_DClink(end) = V_GS2DClink.' * I_GS2DClink;

            % dynamics of "dc link"
            RG  = obj.parameter_DClink{:,'RG'};
            Gsw = obj.parameter_DClink{:,'Gsw'};
            Cdc = obj.parameter_DClink{:,'Cdc'};
            dvdc = ( ( sum(power_sent_to_DClink) - RG*(IG.')*IG )/(2*vdc) - Gsw*vdc )/(Cdc/obj.omega0);


        % set the value of output variable
            dx  = vertcat(dvdc, dx_GS, dx_PS{:});

            con = I - (sum(I_PS2bus) - I_GS2bus);
            
        end
        
        function x_st = set_equilibrium(obj, V, I)
            obj.a_nx = obj.get_a_nx;
            obj.a_nu = obj.get_a_nu;
        end

    end
end