function case_num = categorise_case(Filter_data)
% categorise case
% Possible Cases
% | No.| Target_Class | Door_status  | Belt_status | Movement_status |
% --------------------------------------------------------------------
% | 1. |     Human    | opened       | belt        | movement        |
% --------------------------------------------------------------------
% | 2. |     Human    | opened       | belt        | nomovement      |
% --------------------------------------------------------------------
% | 3. |     Human    | opened       | nobelt      | movement        |
% --------------------------------------------------------------------
% | 4. |     Human    | opened       | bobelt      | nomovement      |
% --------------------------------------------------------------------
% | 5. |     Empty    | opened       | -           | -               |
% --------------------------------------------------------------------
% | 6. |     Human    | closed       | belt        | movement        |
% --------------------------------------------------------------------
% | 7. |     Human    | closed       | belt        | nomovement      |
% --------------------------------------------------------------------
% | 8. |     Human    | closed       | nobelt      | movement        |
% --------------------------------------------------------------------
% | 9. |     Human    | closed       | nobelt      | nomovement      |
% --------------------------------------------------------------------
% | 10. |    Empty    | closed       | -           | -               |
% --------------------------------------------------------------------
% Door Status
case_num = 0;
if strcmp(Filter_data.door, "opened")
    % Subjects (Empty Seat, Human)
    if strcmp(Filter_data.target_class, "Human")
        % Belt Status
        if strcmp(Filter_data.belt, "belt")
            % Movement Status
            if strcmp(Filter_data.movement, "movement")
                case_num = 1;
            elseif strcmp(Filter_data.movement, "nomovement")
                case_num = 2;
            end
        elseif strcmp(Filter_data.belt, "nobelt")
            % Movement Status
            if strcmp(Filter_data.movement, "movement")
                case_num = 3;
            elseif strcmp(Filter_data.movement, "nomovement")
                case_num = 4;
            end
        end
    elseif strcmp(Filter_data.target_class, "Empty")
        case_num = 5;
    end
elseif strcmp(Filter_data.door, "closed")
    if strcmp(Filter_data.target_class, "Human")
        % Belt Status
        if strcmp(Filter_data.belt, "belt")
            % Movement Status
            if strcmp(Filter_data.movement, "movement")
                case_num = 6;
            elseif strcmp(Filter_data.movement, "nomovement")
                case_num = 7;
            end
        elseif strcmp(Filter_data.belt, "nobelt")
            % Movement Status
            if strcmp(Filter_data.movement, "movement")
                case_num = 8;
            elseif strcmp(Filter_data.movement, "nomovement")
                case_num = 9;
            end
        end
    elseif strcmp(Filter_data.target_class, "Empty")
        case_num = 10;
    end
end

end