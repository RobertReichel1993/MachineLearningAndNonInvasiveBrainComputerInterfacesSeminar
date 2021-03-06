function showErdsBands(r1, show_bands, a, color )

    %hold on
    for i_bands = 1 : size(show_bands,1)
        set( gcf, 'CurrentAxes', a{show_bands(i_bands,1)});
        %if( show_bands(i_bands,1) == counter_plots )
              handle = patch( [r1.t_plot(1), r1.t_plot(end), r1.t_plot(end), r1.t_plot(1)], ...
                  [show_bands(i_bands,2), show_bands(i_bands,2), show_bands(i_bands,3), show_bands(i_bands,3)], [0,0,0] );
              set(handle,'FaceAlpha',0.25);
              set(handle,'FaceColor', color );
              set(handle,'EdgeColor', color );
        %end
    end
    %hold off