% mapFilename = 'MappaHMRcoreLAST.svg';
% enrFilename = 'R_K_F.txt';
% col_pV = 2;
% col_FC = 3;
%
% pVthr = 0.05;
% FCthr = 0.263;

function colorZscore_HMRmap(mapFilename, enrFilename, col_pV, col_FC, pVthr, FCthr, Ctitle, outFilename)

minSpess = 2.0;
maxSpess = 12.0;

colorUP = [1 0 0]; %red
colorDW = [0 0 1]; %blue

colorNS = [.7451 .7451 .7451]; %grey

colorBlack = [0 0 0];

% figure() %apre figura per colormap
% livelli = 1024;
% cmap = colormap(hsv(livelli)); %color map di 1024 liveli
% close %chiude la figura
%
% cmap = cmap(1:round((livelli-livelli*0.1)),:); %rimosso 10% finale perch� � lo stesso colore dei valori iniziale

dom = xmlread(mapFilename);
g = dom.getElementsByTagName('path');
%g = g.item(0);
%totPath = g.getElementsByTagName('path'); %~500 path

if ~istable(enrFilename)
enrTab = readtable(enrFilename); %legge tabella arricchimento
else
    enrTab = enrFilename; %� passata direttamente la tabella
end

FC = enrTab.(col_FC);

absFC = abs(FC);

min_FC = min(absFC);
max_FC = max(absFC(absFC~=Inf));

FCthick = mapInRange(absFC, min_FC, max_FC, minSpess, maxSpess);
FCthick(absFC==Inf) = maxSpess; %spessore per Inf

FCthick(enrTab.(col_FC)<0) = FCthick(enrTab.(col_FC)<0)*-1;

for i=0:g.getLength-1
    elem_i = g.item(i);
    if ~isempty(strfind(elem_i.getClass, 'DeferredElementImpl')) %se � un elemento
        % if strcmp(elem_i.getTagName, 'path') || strcmp(elem_i.getTagName, 'line')
        R_name = char(elem_i.getAttribute('id'));
        if startsWith(R_name,'R_')
            idT = find(strcmp(enrTab.(1), R_name(3:end)));
            %disp(R_name);
            R_style = char(elem_i.getAttribute('style'));
            if ~isempty(idT) && ~isnan(enrTab.(col_pV)(idT))
                if enrTab.(col_pV)(idT) > pVthr %se non significativa
                    R_style = setStyle(R_style, colorNS, minSpess, true);
                else
                    if abs(enrTab.(col_FC)(idT)) < FCthr %nessun FC
                        R_style = setStyle(R_style, colorNS, minSpess, false);
                    else
                        if enrTab.(col_FC)(idT) < 0
                            R_style = setStyle(R_style, colorDW, abs(FCthick(idT)), false);
                        else
                            R_style = setStyle(R_style, colorUP, FCthick(idT), false);
                        end
                    end
                    %R_style = setStyle(R_style, colorNS, minSpess, true);
                end
            else
                R_style = setStyle(R_style, colorBlack, minSpess, false);
            end
            %settare il nuovo style
            elem_i.setAttribute('style', R_style);
            %disp(R_style)
        end
        % end
    end
end

p = dom.getElementsByTagName('flowPara');
for i=0:p.getLength-1
    elem_i = p.item(i);
    if ~isempty(strfind(elem_i.getClass, 'DeferredElementImpl')) %se � un elemento
        attr = char(elem_i.getAttribute('id'));
        if strcmp(attr, 'TitleText')
            elem_i.setTextContent(Ctitle)
        end
        if strcmp(attr, 'Val_FC_min')
            elem_i.setTextContent(['min: ' num2str(min(FC(FC~=-Inf)), 2)])
        end
        if strcmp(attr, 'Val_FC_max')
            elem_i.setTextContent(['max: ' num2str(max(FC(FC~=Inf)), 2)])
        end
    end
    
end

%                 if strcmp(R_name, 'TitleText')
%                 style="font-style:normal;font-variant:normal;font-weight:bold;font-stretch:normal;font-size:45px;font-family:sans-serif;-inkscape-font-specification:'sans-serif Bold'">TITOLO: TITOLOTITOLO </flowPara></flowRoot><flowRoot
%                 Title = char(elem_i.getAttribute('style'));
%                 regexprep(R_style, ';stroke-dasharray:\w+;', ';stroke-dasharray:5,5;');
%                 ">TITOLO: TITOLOTITOLO </flowPara>
%                 elseif strcmp(R_name, 'Val_FC_Min')
%                 id="Val_FC_Min">min: </flowPara></flowRoot><flowRoot
%                 elseif strcmp(R_name, 'Val_FC_max')
%                 id="Val_FC_max">max:</flowPara></flowRoot></svg>
%                 end


xmlwrite(outFilename, dom);

end

function strOut = rgb2hex(colorRGB)
strOut = [dec2hex(round(colorRGB(1)*255),2) dec2hex(round(colorRGB(2)*255),2) dec2hex(round(colorRGB(3)*255),2)];
end

function R_style = setStyle(R_style, strokeColor, strokeWidth, dashed)

strColor = rgb2hex(strokeColor);
R_style = regexprep(R_style, ';stroke:#\w+;', [';stroke:#', strColor, ';']);

strWidth = num2str(strokeWidth);
R_style = regexprep(R_style, ';stroke-width:\d*.\d*', [';stroke-width:', strWidth, ';']);

if dashed
    if ~isempty(regexp(R_style, ';stroke-dasharray:\w+;', 'once'))
        R_style = regexprep(R_style, ';stroke-dasharray:\w+;', ';stroke-dasharray:5,5;');
    else
        R_style = [R_style, ';stroke-dasharray:5,5;'];
    end
else
    
    if ~isempty(regexp(R_style, ';stroke-dasharray:\w+;', 'once'))
        R_style = regexprep(R_style, ';stroke-dasharray:\w+;', ';stroke-dasharray:none;');
    else
        R_style = [R_style, ';stroke-dasharray:none;'];
    end
end

R_style = strrep(R_style, ';;', ';');

end


