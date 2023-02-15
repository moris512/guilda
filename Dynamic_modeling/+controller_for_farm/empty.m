classdef empty < handle

    properties(SetAccess = protected)
        x_equilibrium = [];
    end

    properties(Access = private)
        connected_component
        parameter_name = [];
    end


    methods

        function obj = empty(comp)
            obj.connected_component = comp;
        end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 状態や入力の個数・名前を取得する関数 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function nx   = get_nx(obj);        nx   = 0;  end
        function name = get_x_name(obj);    name = []; end
        function nu   = get_nu(obj);        nu   = 0;  end
        function name = get_port_name(obj); name = []; end


    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % ダイナミクスを決定する関数 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%
        function [dx, Iref] = get_dx_Iref(obj,varargin)
            dx   = [];
            Iref = nan(2,1);
        end

        function [dx, mdq] = get_dx_mdq(obj,varargin)
            dx = [];
            mdq = nan(2,1);
        end

        function x_st = set_equilibrium(obj,varargin)
            x_st = [];
            obj.x_equilibrium = x_st;
        end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % パラメータの設定や取得に関わる関数 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function para = parameter(obj)
            npara = numel(obj.parameter_name);
            if npara==0
                para = [];
            else
                for i = 1:numel(obj.parameter_name)
                    para.(obj.parameter_name{i}) = obj.(obj.parameter_name{i});
                end
                para = struct2table(para);
            end
        end

        function set_parameter(obj,parameter)
            npara = numel(obj.parameter_name);
            if npara~=0
                for i = 1:numel(obj.parameter_name)
                    obj.(obj.parameter_name{i}) = parameter(:,obj.parameter_name{i});
                end
            end
        end

    end

end