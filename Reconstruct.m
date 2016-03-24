classdef Reconstruct < handle

    properties
        hReconFig
        axRecon
        sliderThreshold
        textReconMax
        textReconMin
        textThreshold
    end
    
    methods
        function self = Reconstruct
self.hReconFig = hgload('Recon.fig')
         
self.axRecon = findobj(self.hReconFig,'tag','axRecon');
self.sliderThreshold = findobj(self.hReconFig,'tag','sliderThreshold');
self.textReconMax = findobj(self.hReconFig,'tag','textReconMax');
self.textReconMin = findobj(self.hReconFig,'tag','textReconMin');
self.textThreshold = findobj(self.hReconFig,'tag','textThreshold');
    end
    end
end
