starts_adjusted=0;      % Concentrated adjusted onsets
starts_cue=0;           % Concentrated cue starts
count_starts=0;         % Number of movement onsets
stops_adjusted=0;       % Concentrated adjusted ends
stops_cue=0;            % Concentrated cue stops
count_stops=0;          % Number of movement ends
%%
for su=1:20         % Participants 1 to 20

load(strcat('s',num2str(su))); % Load data
%%
class_copy=class;       % Replicating class data
adjusted_class_ = double(class) + double(repetition)/10;  % Adjusted class comprisisng information about both, class and repetition
%
class_copy(find(class_copy>0))=1; % Binarizing class
%
meta_force=zeros(length(force(:,1)),1);     % Processed and cumulated hand force
base_force=mean(force(2000:4000,:));        % Hand force at rest (before movement cue)

%% For each movement rest forces (mean force during 1 s preceding movement
% cue) were subtracted from the cumulated forces

for i=5000:length(class_copy)
    if (class_copy(i)==1 && class_copy(i-1)==0)
        base_force=mean(force(i-2000:i,:));
    end
    meta_force(i)=sum(abs(force(i,:)-base_force));
end

%% Adjustment of the movement onsets

for i=5000:length(class_copy)-15000
    if (class_copy(i)==1 && class_copy(i-1)==0)     % Detection of cue starts
        low_force=min(meta_force(i-2000:i));        % Hand forces minumum during rest period preceeding movement
        high_force=max(meta_force(i:i+10000));      % Maximal hand forces during the movement
        j=(i-1000);                                 % Offset the onset finder for 500 ms
        count_starts=count_starts+1;                % Increment global counter (for all 20 volunteers)
        starts_cue(count_starts)=i;                 % Save timestamp (in samples) of the onset
        starts_adjusted(count_starts)=i;            % Initialize adjusted onset value
        while (j<(i+8000))                                          % Search for movement onset in range (0.5-4) s
            if meta_force(j)<low_force+0.5*(high_force-low_force);  % Check if the force is below 50% of the amplitude
                starts_adjusted(count_starts)=j;                    % Update adjusted onset value
                adjusted_class_(j)=adjusted_class_(i-20);           % Update adjusted class
                j=j+1;                                              % Increment onset finder
                
            end
            if meta_force(j)>low_force+0.5*(high_force-low_force);  % Check if the force exceeds 50% of the amplitude
                if (j<i)                                            % If force exceeds 50% before the cue (early reaction)
                    starts_adjusted(count_starts)=j;                % Update adjusted onset value
                    adjusted_class_(j:i+10)=adjusted_class_(i+20);  % Update adjusted class
                end
                j=j+10001;                                          % Condition to exit the loop
            end
        end
    end
    
end

%% Adjustment of the movement ends

for i=5000:length(class_copy)-15000
    if (class_copy(i)==0 && class_copy(i-1)==1)                     % Detection of cue ends
        high_force=median(meta_force(i-2000:i));                    % Hand forces maximum during the movement
        low_force=min(meta_force(i:i+10000));                       % Hand forces minumum during rest period after the movement
        j=(i-2000);                                                 % Offset the end finder for 500 ms
        count_stops=count_stops+1;                                  % Increment global counter (for all 20 volunteers)
        stops_cue(count_stops)=i;                                   % Save timestamp (in samples) of the movement end
        stops_adjusted(count_stops)=i;
        while (j<(i+9000))                                          % Search for movement end in range (0.5-4.5) s
            if meta_force(j)>low_force+0.5*(high_force-low_force);  % Check if the force exceeds 50% of the amplitude
                stops_adjusted(count_stops)=j;                      % Update adjusted end value
                adjusted_class_(j)=adjusted_class_(i-20);           % Update adjusted class
                j=j+1;                                              % Increment the end finder
            end
            if meta_force(j)<low_force+0.5*(high_force-low_force);  % Check if the force exceeds 50% of the amplitude
                if (j<i)                                            % If force drops below 50% before the cue (early reaction)
                    stops_adjusted(count_stops)=j;                  % Update adjusted end value
                    adjusted_class_(j:i+10)=adjusted_class_(i+20);  % Update adjusted class
                end
                j=j+11001;
            end
        end
    end
    
end
%%


%%
all_adjusted_class{su}=adjusted_class_;

end
