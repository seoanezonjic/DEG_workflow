#! /usr/bin/env bash
#SBATCH --mem='60gb'
#SBATCH --constraint=cal
#SBATCH --time='02:00:00'
hostname

echo "Preparing multiVCF"
mkdir -p $VARIANT_RESULTS_FOLDER
module load bcftools/1.21
source ~soft_bio_267/initializes/init_R
vcf=`find $MAPPING_RESULTS_FOLDER/*/gatk_0000/filtered.vcf.gz`
bcftools merge $vcf --output-type z --output $VARIANT_RESULTS_FOLDER/"tmp.vcf.gz"
bcftools norm -m- $VARIANT_RESULTS_FOLDER/"tmp.vcf.gz" -o $VARIANT_RESULTS_FOLDER/"combined.vcf.gz"
header=`bcftools view -h $VARIANT_RESULTS_FOLDER/"combined.vcf.gz" | tail -n 1`
bcftools view -H $VARIANT_RESULTS_FOLDER/"combined.vcf.gz" -o $VARIANT_RESULTS_FOLDER/"tmp_variants.txt"
grep PASS $VARIANT_RESULTS_FOLDER/"tmp_variants.txt" > $VARIANT_RESULTS_FOLDER/"all_variants.txt"
rm $VARIANT_RESULTS_FOLDER/"tmp_variants.txt"
sed -i "1i $header" $VARIANT_RESULTS_FOLDER/"all_variants.txt"
sed -i "s/#//g" $VARIANT_RESULTS_FOLDER/"all_variants.txt"
effects=`find $MAPPING_RESULTS_FOLDER/*/gatk_0000/var_effects.txt`
rm $VARIANT_RESULTS_FOLDER/"all_variant_effects.txt"
for effect in $effects; do
	cat $effect >> $VARIANT_RESULTS_FOLDER/"all_variant_effects.txt"
done
if [ ! -s $VARIANT_RESULTS_FOLDER/"all_variants.txt" ]; then
	echo No variants have passed the filters.
	echo -e No_variants_identified > $VARIANT_RESULTS_FOLDER/"all_variants.txt"
fi
if [ ! -s $VARIANT_RESULTS_FOLDER/"all_variant_effects.txt" ]; then
	echo No known variants have been identified. No variant effects predicted.
	echo -e No_known_variants_detected > $VARIANT_RESULTS_FOLDER/"all_variant_effects.txt"
fi
echo "Command called: html_report.R -t $REPORT_TEMPLATES_FOLDER'/variants_report.txt' -o $VARIANT_RESULTS_FOLDER'/variants_report.html' -d $VARIANT_RESULTS_FOLDER'/all_variants.txt',$VARIANT_RESULTS_FOLDER'/all_variant_effects.txt' --title 'Variant analysis report'"
html_report.R -t $REPORT_TEMPLATES_FOLDER'/variants_report.txt' -o $VARIANT_RESULTS_FOLDER'/variants_report.html' -d $VARIANT_RESULTS_FOLDER'/all_variants.txt',$VARIANT_RESULTS_FOLDER'/all_variant_effects.txt' --title 'Variant analysis report'
echo "Report built in "$VARIANT_RESULTS_FOLDER"/variants_report.html"
