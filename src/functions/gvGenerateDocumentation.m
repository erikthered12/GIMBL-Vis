function gvGenerateDocumentation
%GVGENERATEDOCUMENTATION - Build GIMBL-Vis documentation

cwd = pwd; % store current working dir

cd(getPath('gv'))

m2html('mfiles',{'src'},...
       'htmldir','_docs/offline_docs',...
       'recursive','on',...
       'global','on',...
       'template','frame',...
       'index','menu',...
       'graph','on');


cd(cwd);