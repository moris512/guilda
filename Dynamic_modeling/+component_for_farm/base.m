classdef base < handle

    properties(SetAccess = protected)
        Inner_loop_controller
        Outer_loop_controller
        
        id = '';
    end

    properties(Access = private)
        connected_farm
        a_nx
        a_nu
    end

    properties
        parameter_plant = table();
        parameter_converter = table();
    end

    methods(Abstract)
        [dx, I_tobus, V_toDClink, I_toDClink] = get_dx_VI(x, Vbus, vdc, u_GS);
        x_st = set_equilibrium(vaargin)
    end

    methods
        %%%%%%%%%%%%%%%
        % constructor %
        %%%%%%%%%%%%%%%
        function obj = base(comp)
            obj.connected_farm = comp;
            obj.Inner_loop_controller = controller_for_converter.empty(obj);
            obj.Outer_loop_controller = controller_for_converter.empty(obj);
        end
 

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % function to set/remove elements %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%%%%
        function set_id(obj,id)
            obj.id = id;
        end
        function set_Inner_controller(obj,c)
            obj.Inner_loop_controller = c;
        end
        function set_Outer_controller(obj,c)
            obj.Outer_loop_controller = c;
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % function to get number/name of states or input/output ports %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function nx = get_nx_plant(obj);        nx=0; end
        function nx = get_nx_converter(obj);    nx=0; end
        function nu = get_nu_plant(obj);        nu=0; end
        function nu = get_nu_converter(obj);    nu=0; end
        function name = get_x_name_plant(obj);          name =[]; end
        function name = get_x_name_converter(obj);      name =[]; end
        function name = get_port_name_plant(obj);       name =[]; end
        function name = get_port_name_converter(obj);   name =[]; end

        function set_a_nxu(obj)
            obj.a_nx = [obj.get_nx_plant; obj.get_nx_converter; obj.Inner_loop_controller.get_nx; obj.Outer_loop_controller.get_nx];
            obj.a_nu = [obj.get_nu_plant; obj.get_nx_converter; obj.Inner_loop_controller.get_nu; obj.Outer_loop_controller.get_nu];
        end

        function nx = get_nx(obj); nx = sum(obj.a_nx); end
        function nu = get_nu(obj); nu = sum(obj.a_nu); end

        function name = get_x_name(obj)
            name = [cellfun(@(c) [c,'Plant'], obj.get_x_name_plant),...
                    cellfun(@(c) [c,obj.id,'C'], obj.get_x_name_converter),...
                    cellfun(@(c) [c,obj.id,'in'], obj.Inner_loop_controller.get_x_name),...
                    cellfun(@(c) [c,obj.id,'out'], obj.Outer_loop_controller.get_x_name)];
        end
        function name = get_port_name(obj)
            name = [cellfun(@(c) [c,'Plant'], obj.get_port_name_plant),...
                    cellfun(@(c) [c,obj.id,'C'], obj.get_port_name_converter),...
                    cellfun(@(c) [c,obj.id,'in'], obj.Inner_loop_controller.get_port_name),...
                    cellfun(@(c) [c,obj.id,'out'], obj.Outer_loop_controller.get_port_name)];
        end


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % パラメータの設定や取得に関わる関数 %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function para = parameter(obj)
            para{1} = obj.parameter_plant;
            para{2} = obj.parameter_converter;
            para{3} = obj.Inner_loop_controller.parameter;
            para{4} = obj.Outer_loop_controller.parameter;
            tag = {'Plant',[obj.id,'C'],[obj.id,'in'],[obj.id,'out']};
            for i =1:4
                para{i}.Properties.VariableNames = cellfun(@(c) [c,tag{i}], para{i}.Properties.VariableNames, 'UniformOutput', false);
            end
            para = horzcat(para{:});
        end
    end

end