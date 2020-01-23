

### install rPraat if you don't have it on your computer
install.packages("rPraat")


###create function label_vot
label_vot<-function(textgrid_directory,textgrids_output_folder,labels_to_change,new_label){
  library(rPraat)
  textgrids<-list.files(path = textgrid_directory, pattern = ".TextGrid")
  for (t in textgrids){
    tg<-tg.read(paste(textgrid_directory,t,sep=""))
    tg2<-tg.insertNewIntervalTier(tg,3,"vot")
    tg2$vot<-tg2$phones
    tg2$vot$name<-"vot"
    for (i in c(1:length(tg2$vot$label))){
      if (tg2$vot$label[i]%in%labels_to_change){
        tg2$vot$label[i] <- new_label
      }
    }
    tg.write(tg2,paste(textgrids_output_folder,t,sep=""))
  }
}

### set parameters
textgrid_directory<-"/Users/zhiyangao/Desktop/test/"
labels_to_change<-c("P","T","K","p","t","k")
new_label<-"vot"
textgrids_output_folder<-"/Users/zhiyangao/Desktop/test/new/"

label_vot(textgrid_directory,textgrids_output_folder,labels_to_change,new_label)





