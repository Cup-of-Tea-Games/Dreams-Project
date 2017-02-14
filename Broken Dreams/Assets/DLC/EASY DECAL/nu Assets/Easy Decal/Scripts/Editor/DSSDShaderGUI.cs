using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace ch.sycoforge.Decal.Editor
{

    public class DSSDShaderGUI : ShaderGUI
    {
        //-----------------------------
        // Fields
        //-----------------------------
        private bool firstTimeApply = true;

        private MaterialProperty albedoMap;
        private MaterialProperty bumpMap;
        private MaterialEditor materialEditor;



        //-----------------------------
        // Methods
        //-----------------------------
        private void FindProperties(MaterialProperty[] props)
        {
            this.albedoMap = ShaderGUI.FindProperty(ShaderConstants.DIFFUSE_TEXTURE, props);
            this.bumpMap = ShaderGUI.FindProperty(ShaderConstants.NORMAL_TEXTURE, props);
        }

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            this.FindProperties(props);
            this.materialEditor = materialEditor;
            Material material = materialEditor.target as Material;
            this.ShaderPropertiesGUI(material);
            if (!this.firstTimeApply)
                return;
            SetMaterialKeywords(material);
            this.firstTimeApply = false;
        }

        public void ShaderPropertiesGUI(Material material)
        {
            EditorGUIUtility.labelWidth = 0.0f;
            EditorGUI.BeginChangeCheck();

            GUILayout.Label("Main Maps", EditorStyles.boldLabel, new GUILayoutOption[0]);

            this.DoAlbedoArea(material);

            this.materialEditor.TexturePropertySingleLine(new GUIContent("Normal Map", "Normal Map"), this.bumpMap, null);

            if(EditorGUI.EndChangeCheck())
            {
                SetMaterialKeywords(material);
            }
        }

        private void DoAlbedoArea(Material material)
        {
            this.materialEditor.TexturePropertySingleLine(new GUIContent("Albedo", "Albedo (RGB) and Transparency (A)"), this.albedoMap, null);
        }
        private static void SetMaterialKeywords(Material material)
        {
            SetKeyword(material, ShaderConstants.KEYWORD_NORMAL, material.GetTexture(ShaderConstants.NORMAL_TEXTURE) != null);
            SetKeyword(material, ShaderConstants.KEYWORD_DIFFUSE, material.GetTexture(ShaderConstants.DIFFUSE_TEXTURE) != null);

        }

        private static void SetKeyword(Material m, string keyword, bool state)
        {
            if (state)
            {
                m.EnableKeyword(keyword);
            }
            else
            {
                m.DisableKeyword(keyword);
            }
        }
    }
}
