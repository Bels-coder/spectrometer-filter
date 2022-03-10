function x = trms(a)

 % Return the root mean square of all the elements of *a*, flattened out.
   x = sqrt(mean(abs(a).^2));
   
end