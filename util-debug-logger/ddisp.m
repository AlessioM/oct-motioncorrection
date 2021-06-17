function ddisp( varargin )
%DDISP debug output

    persistent lastCallTime firstCallTime lastMainMessage lastTotalLength ...
        lastSubMessageLength lastPercentage;
    
    if isempty(firstCallTime)
        lastCallTime = now;
        firstCallTime = now;
        lastTotalLength = 0;
        lastSubMessageLength = 0;
        lastPercentage = 0;
    end
    
    if nargin == 1 && strcmp('LOG_RESET', varargin{1}) %reset the log counters
        firstCallTime = now;
        lastCallTime = now;
        lastTotalLength = 0;
        lastSubMessageLength = 0;
        lastPercentage = 0;
    else
        toPrint = '';
        clearString = '';
        isMain = false;
        
        if nargin < 1   %print an empty line
            toPrint = '';    
        elseif nargin > 1 && ...
                (isempty(varargin{1}) || ...
                (isvector(varargin{1}) &&  ~ischar(varargin{1}))) % sub step

            if isvector(varargin{1}) && numel(varargin{1}) ~= 2
                error('first parameter of sub steps must be either empty or [total, current]');
            end

            if ~isempty(varargin{1})    %calculate new percentage
                lastPercentage = varargin{1}(1) /  varargin{1}(2);
            end 
            
            if nargin == 2
                toPrint = varargin{2};
            elseif nargin > 2    
                toPrint = sprintf(varargin{2}, varargin{3:end});
            end

            clearString = repmat(sprintf('\b'),1,lastTotalLength);
            
            if lastPercentage > 0
                toPrint = sprintf(' [%4.2f]: %s', lastPercentage, toPrint);
            else
                toPrint = sprintf(': %s', toPrint);
            end
            
            lastSubMessageLength = numel(toPrint);
            toPrint = sprintf('%s%s', lastMainMessage, toPrint);

        elseif nargin == 1  %simple main message
            if ismatrix(varargin{1}) && ~ischar(varargin{1})
                toPrint = mat2str(varargin{1});
            else
                toPrint = varargin{1};
            end
            clearString = repmat(sprintf('\b'),1,lastSubMessageLength);
            isMain = true;
        elseif nargin > 1   %formatted main message 
            toPrint = sprintf(varargin{1}, varargin{2:end});
            clearString = repmat(sprintf('\b'),1,lastSubMessageLength);            
            isMain = true;
        end
        

        delaTotal = (now - firstCallTime) * 86400;
        deltaLast = (now - lastCallTime) * 86400;

        if isMain
            lastMainMessage = toPrint;
            lastSubMessageLength = 0;
            lastPercentage = 0;
            lastCallTime = now;
        end

        message = sprintf('\n[%6.1f | %6.1f]: %s', delaTotal, deltaLast, toPrint);    
        lastTotalLength = numel(message);
        fprintf(strcat(clearString, message));
        
    end
end

