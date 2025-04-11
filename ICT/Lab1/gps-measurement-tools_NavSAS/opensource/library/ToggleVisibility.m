function ToggleVisibility(event)
    % Toggle the visibility of the selected line
    obj = event.Peer; % Get the line object
    if strcmp(obj.Visible, 'on')
        obj.Visible = 'off';
    else
        obj.Visible = 'on';
    end
end