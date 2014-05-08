function c = array2cell(a, dim)
% array2cell   convert an array/martix of stuff to a cell array of stuff 
%
% c = array2cell(a, dim)
%
% a - array or ND matrix
% dim - (o) if not given or [], each element of a is placed into
%              its own cell block 
%           else if integer, array2cell works down that dimention
%           only 
%
% c - cell array of the elements of a
%
% Example:
%  array2cell(rand(10,3),2) 
%    produces => {[10x1 double], [10x1 double], [10x1 double]}

  
  if(nargin<2 | length(dim)==0)
    for l=1:size(a,4)
      for k=1:size(a,3)
        for j=1:size(a,2)
          for i=1:size(a,1)
            c{i,j,k,l} = a(i,j,k,l);
          end
        end
      end
    end
  else
    switch(dim)
     case 1
      for i=1:size(a, dim)
        c{i} = a(i,:,:,:); 
      end
     case 2
      for i=1:size(a, dim)
        c{i} = a(:,i,:,:); 
      end
     case 3
      for i=1:size(a, dim)
        c{i} = a(:,:,i,:); 
      end
     case 4
      for i=1:size(a, dim)
        c{i} = a(:,:,:,i); 
      end
     otherwise
      c{1} = a;
    end
  end
  