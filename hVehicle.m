classdef hVehicle < matlab.System

    % Copyright 2022 The MathWorks, Inc.
    properties (Access = private)
        mActorSimulationHdl; 
        mScenarioSimulationHdl; 
        mActor; 
        mLastTime = 0;
    end

    methods (Access=protected)
        function sz = getOutputSizeImpl(~)
            sz = [1 1];
        end

        function st = getSampleTimeImpl(obj)
            st = createSampleTime( ...
                obj, 'Type', 'Discrete', 'SampleTime', 0.02);
        end

        function t = getOutputDataTypeImpl(~)
            t = "double";
        end

        function resetImpl(~)
        end

        function setupImpl(obj)
    
            obj.mScenarioSimulationHdl = ...
                Simulink.ScenarioSimulation.find( ...
                    'ScenarioSimulation', 'SystemObject', obj);
            
            obj.mActorSimulationHdl = Simulink.ScenarioSimulation.find( ...
                'ActorSimulation', 'SystemObject', obj);

            obj.mActor.pose = ...
                obj.mActorSimulationHdl.getAttribute('Pose');

            obj.mActor.velocity = ...
                obj.mActorSimulationHdl.getAttribute('Velocity');

        end
        
        function stepImpl(obj, ~)

            currentTime = obj.getCurrentTime;
            elapsedTime = currentTime - obj.mLastTime;
            obj.mLastTime = currentTime;

            velocity = obj.mActor.velocity;
            pose = obj.mActor.pose;

            pose(1,4) = pose(1,4) + velocity(1) * elapsedTime; % x
            pose(2,4) = pose(2,4) + velocity(2) * elapsedTime; % y
            pose(3,4) = pose(3,4) + velocity(3) * elapsedTime; % z

            obj.mActor.pose = pose;
            
            obj.mActorSimulationHdl.setAttribute('Pose', pose);
        end

        function releaseImpl(~)
        end
    end
end