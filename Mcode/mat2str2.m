function out = mat2str2(x, varargin)
%MAT2STR2 Convert matrix to characters, with support for additional types
%
% out = mat2str2(x)
% out = mat2str2(x, n)
%
% MAT2STR2 works just like MAT2STR, but also supports additional input types and
% matrices with more than 2 dimensions.
%
% Additional types supported:
%   - cell
%   - struct
%   - table
%   - datetime
%   - duration
%
% Notes on particular input data types:
%
% Some aspects of tables are not currently supported: CustomProperties,
% VariableDescriptions, VariableUnits, Description, and DimensionNames are
% lost in the conversion, because there is no table() constructor form that
% accepts them.
%
% durations are only represented precise to the millisecond. The values you
% get back may not exactly 
%
% MAT2STR2 also automatically includes the data type for non-double numerics.
% This is so you always get a string that reconstructs the original value.
% (Unless you pass in n, in which case there will be rounding error.)
%
% See also: MAT2STR

%#ok<*ISMAT>

if ndims(x) > 2
  out = mat2str2_nd(x);
  return
end

if iscell(x)
  out = mat2str2_cell(x, varargin{:});
elseif isstruct(x)
  out = mat2str2_struct(x, varargin{:});
elseif isa(x, 'datetime')
  out = mat2str2_datetime(x);
elseif isa(x, 'duration')
  out = mat2str2_duration(x);
elseif isa(x, 'table')
  out = mat2str2_table(x, varargin{:});
elseif isobject(x)
  % Allow user-defined classes to override mat2str
  out = mat2str(x, varargin{:});
elseif isnumeric(x)
  if isa(x, 'double')
    out = mat2str(x, varargin{:});
  else
    out = mat2str(x, varargin{:}, 'class');
  end
else
  out = mat2str(x, varargin{:});
end

end

function out = mat2str2_nd(x, varargin)
dim = ndims(x);
len = size(x, dim);
strs = cell(1, len);
ixs = repmat({':'}, [1 ndims(x)]);
for i = 1:len
  ixs{dim} = i;
  x_slice = x(ixs{:});
  strs{i} = mat2str2(x_slice, varargin{:});
end
out = ['cat(' num2str(dim) ', ' strjoin(strs, ', ') ')'];
end

function out = mat2str2_cell(c, varargin)
strs = cell(size(c));
for i = 1:numel(c)
  strs{i} = mat2str2(c{i}, varargin{:});
end
out = arrange_strs_as_matrix(strs, {'{' '}'});
end

function out = mat2str2_struct(s, varargin)
c = struct2cell(s);
cell_expr = mat2str2(c, varargin{:});
fields = fieldnames(s)';
out = ['cell2struct(' cell_expr ', ' mat2str2(fields) ')'];
end

function out = mat2str2_datetime(x)
num_str = mat2str2(datenum(x));
out = ['datetime(' num_str ', ''ConvertFrom'', ''datenum'')'];
end

function out = mat2str2_duration(x)
dur = x;
default_format = 'hh:mm:ss';
strs = cell(size(x));
format = x.Format;
is_default_format = isequal(format, default_format);
dur.Format = 'hh:mm:ss.SSS';
strs = reshape(cellstr(char(dur(:))), size(dur));
strs_expr = mat2str2(strs);
out = ['duration(' strs_expr];
if ~is_default_format
  out = [out ', ''Format'', ''' format ''''];
end
out = [out ')'];
end

function out = mat2str2_table(t, varargin)
n_vars = width(t);
var_strs = cell(1, n_vars);
for i = 1:n_vars
  var_strs{i} = mat2str2(t{:,i}, varargin{:});
end
ctor_args = var_strs;
ctor_args = [ctor_args {'''VariableNames''', mat2str2(t.Properties.VariableNames)}];
if ~isempty(t.Properties.RowNames)
  ctor_args = [ctor_args {'''RowNames''', mat2str2(t.Properties.RowNames)}];
end
% Darn it: these constructor forms don't actually work
% if ~isempty(t.Properties.VariableDescriptions)
%   ctor_args = [ctor_args {'''VariableDescriptions''', mat2str2(t.Properties.VariableDescriptions)}];
% end
% if ~isempty(t.Properties.VariableUnits)
%   ctor_args = [ctor_args {'''VariableUnits''', mat2str2(t.Properties.VariableUnits)}];
% end
% if ~isempty(t.Properties.Description)
%   ctor_args = [ctor_args {'''Description''', mat2str2(t.Properties.Description)}];
% end
% if ~isequal(t.Properties.DimensionNames, {'Row', 'Variables'})
%   ctor_args = [ctor_args {'''DimensionNames''', mat2str2(t.Properties.DimensionNames)}];
% end
out = ['table(' strjoin(ctor_args, ', ') ')'];
end

function out = arrange_strs_as_matrix(strs, brackets)
if nargin < 2 || isempty(brackets); brackets = { '[' ']' }; end

rows = cell(size(strs, 1), 1);
for i_row = 1:size(strs, 1)
  row = strjoin(strs(i_row,:), ' ');
  rows{i_row} = row;
end
out = [brackets{1} strjoin(rows, {'; '}) brackets{2}];
end

