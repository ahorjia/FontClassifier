using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Text;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DemoFontSimilarity
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            ReadSimilarityMatrix();
            ReadFontNames();
            refFonts.DataSource = new BindingSource(similarity_dict, null);
            refFonts.DisplayMember = "Key";
            refFonts.ValueMember = "Value";
        }

        private void ReadFontNames()
        {
            var fontNamesLines = File.ReadAllLines(@"..\..\fontNames.txt");
            FontNames = new List<string>(fontNamesLines);
        }

        IList<string> FontNames = null;
        Dictionary<string, IList<string>> similarity_dict = null;

        private void ReadSimilarityMatrix()
        {
            similarity_dict = new Dictionary<string, IList<string>>();

            using (var fs = File.OpenRead(@"..\..\similarity_df.csv"))
            using (var reader = new StreamReader(fs))
            {
                List<string> listA = new List<string>();
                List<string> listB = new List<string>();
                var line_header = reader.ReadLine();
                var ref_font_names = line_header.Split(',');

                foreach (var ref_font_name in ref_font_names.Skip(1))
                    similarity_dict[ref_font_name] = new List<string>();

                while (!reader.EndOfStream)
                {
                    var line = reader.ReadLine();
                    var names = line.Split(',');

                    int nameCounter = 1;
                    foreach (var ref_font_name in ref_font_names.Skip(1))
                    {
                        similarity_dict[ref_font_name].Add(names[nameCounter++]);
                    }
                }
            }
        }

        private Font GetFont(string fileName)
        {
            PrivateFontCollection FontCollection = new PrivateFontCollection();
            string fontPath = string.Format("{0}\\{1}.ttf", FontsFolder, fileName);
            if (!File.Exists(fontPath))
                fontPath = string.Format("{0}\\{1}.otf", FontsFolder, fileName);

            if (!File.Exists(fontPath))
                return null;

            FontCollection.AddFontFile(fontPath);
            return new Font((FontFamily)FontCollection.Families[0], 24f);
        }

        private const string FontsFolder = @"C:\Users\aghorbani\Dropbox\MyFonts\";

        private void DrawLabelText(Label lbl, string font_name, Color color)
        {
            var font = GetFont(font_name);
            if (font == null)
                return;

            Graphics g = lbl.CreateGraphics();
            g.Clear(SystemColors.Control);
            SolidBrush myBrush = new SolidBrush(color);
            g.DrawString("quick brown fox jumps over the lazy dog!", font, myBrush, new
               RectangleF(10, 10, 1000, 500));
        }

        private void comboBox1_SelectedIndexChanged(object sender, EventArgs e)
        {
            string referenceFontName = null;
            IList<string> replacementFonts = null;

            if (this.refFonts.SelectedValue is IList<string>)
            {
                referenceFontName = this.refFonts.Text;
                replacementFonts = (IList<string>)this.refFonts.SelectedValue;
            }
            else
            {
                var similarFonts = (KeyValuePair<string, IList<string>>)this.refFonts.SelectedValue;
                referenceFontName = similarFonts.Key;
                replacementFonts = similarFonts.Value;
            }

            lblFontNames.Text = string.Join(",", replacementFonts.ToArray());

            DrawLabelText(labelRef, referenceFontName, Color.Blue);
            DrawLabelText(labelFont1, replacementFonts[0], Color.Green);
            DrawLabelText(labelFont2, replacementFonts[1], Color.Green);
            DrawLabelText(labelFont3, replacementFonts[2], Color.Green);
            DrawLabelText(labelFont4, replacementFonts[3], Color.Green);
            DrawLabelText(labelFont5, replacementFonts[4], Color.Green);

            select_random_fonts();
        }

        private void select_random_fonts()
        {
            Random r = new Random();

            DrawLabelText(label1, FontNames[r.Next(FontNames.Count)], Color.Red);
            DrawLabelText(label2, FontNames[r.Next(FontNames.Count)], Color.Red);
            DrawLabelText(label3, FontNames[r.Next(FontNames.Count)], Color.Red);
            DrawLabelText(label4, FontNames[r.Next(FontNames.Count)], Color.Red);
            DrawLabelText(label5, FontNames[r.Next(FontNames.Count)], Color.Red);
        }
    }
}
